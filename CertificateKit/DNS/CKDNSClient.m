//
//  CKDNSClient.m
//
//  LGPLv3
//
//  Copyright (c) 2023 Ian Spence
//  https://tlsinspector.com/github.html
//
//  This library is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with this library.  If not, see <https://www.gnu.org/licenses/>.

#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#import <arpa/inet.h>
#import "CKDNSClient.h"
#import "CKDNSResult.h"
#import "NSData+HexString.h"
#import "NSData+Base64URL.h"
#import "CKCurlCommon.h"
#import "NSString+SplitFirst.h"
#import "NSData+ByteAtIndex.h"

@interface CKDNSClient () {
    dispatch_queue_t dnsClientQueue;
}

#if DEBUG
@property (nonatomic) BOOL _DANGEROUS_DISABLE_SSL_VERIFY;
#endif

@end

@implementation CKDNSClient

static id instance;

typedef struct _DNS_HEADER
{
    unsigned short idn;
    unsigned char  rd     :1;
    unsigned char  tc     :1;
    unsigned char  aa     :1;
    unsigned char  opcode :4;
    unsigned char  qr     :1;
    unsigned char  rcode  :4;
    unsigned char  cd     :1;
    unsigned char  ad     :1;
    unsigned char  z      :1;
    unsigned char  ra     :1;
    unsigned short qlen;
    unsigned short alen;
    unsigned short aulen;
    unsigned short adlen;
} DNS_HEADER;

typedef struct _HTTP_RESPONSE {
    char * response;
    size_t size;
} HTTP_RESPONSE;

+ (CKDNSClient *) sharedClient {
    if (instance == NULL) {
        CKDNSClient * client = [CKDNSClient new];
        client->dnsClientQueue = dispatch_queue_create("com.ecnepsnai.CertificateKit.CKDNSClient", NULL);
        instance = client;
    }

    return instance;
}

#if DEBUG
- (void) DANGEROUS_DISABLE_SSL_VERIFY {
    self._DANGEROUS_DISABLE_SSL_VERIFY = true;
}
#endif

- (void) resolve:(NSString *)host ofAddressVersion:(CKIPVersion)addressVersion onServer:(NSString *)server completed:(void (^)(CKDNSResult *, NSError *))completed {
    dispatch_async(dnsClientQueue, ^{
        [self doResolve:host ofAddressVersion:addressVersion onServer:server completed:completed];
    });
}

- (void) doResolve:(NSString *)host ofAddressVersion:(CKIPVersion)addressVersion onServer:(NSString *)server completed:(void (^)(CKDNSResult *, NSError *))completed {
    CKDNSRecordType recordType;
    switch (addressVersion) {
        case CKIPVersionIPv4:
            recordType = CKDNSRecordTypeA;
            break;
        case CKIPVersionIPv6:
            recordType = CKDNSRecordTypeAAAA;
            break;
        case CKIPVersionAutomatic: {
            NSError * autoError;
            recordType = [self getPreferredRecordTypeWithError:&autoError];
            if (autoError != nil) {
                PError(@"[DOH] Unable to get preferred record type: %@", autoError.localizedDescription);
                completed(nil, autoError);
                return;
            }
            break;
        }
    }

    uint16_t idn = arc4random_uniform(UINT16_MAX);
    NSError * requestError;
    NSMutableString * hostToQuery = [host mutableCopy];
    if ([hostToQuery characterAtIndex:hostToQuery.length-1] != '.') {
        [hostToQuery appendString:@"."];
    }

    NSData * request = [self requestFor:hostToQuery type:recordType idn:idn withError:&requestError];
    if (requestError != nil) {
        completed(nil, requestError);
        return;
    }

    NSMutableString * url = [server mutableCopy];
    if ([url containsString:@"?"]) {
        [url appendString:@"&dns="];
    } else {
        [url appendString:@"?dns="];
    }
    [url appendString:[request base64URLEncodedValue]];

    CURL * curl = [[CKCurlCommon sharedInstance] curlHandle];
    if (!curl) {
        completed(nil, MAKE_ERROR(1, @"curl init error"));
        return;
    }

    // Prepare curl verbose logging but only use it if in debug level
    // We have to use an in-memory file since curl expects a file pointer for STDERR
    static char *buf;
    static size_t len;
    FILE * curlout = NULL;
    if (CKLogging.sharedInstance.level == CKLoggingLevelDebug) {
        curlout = open_memstream(&buf, &len);
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
        curl_easy_setopt(curl, CURLOPT_STDERR, stderr);
    }

    unsigned long contentLength;
    HTTP_RESPONSE curldata;
    curldata.response = malloc(0);
    curldata.size = 0;
    curl_easy_setopt(curl, CURLOPT_URL, url.UTF8String);
    curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, curl_doh_header_callback);
    curl_easy_setopt(curl, CURLOPT_HEADERDATA, &contentLength);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_doh_write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&curldata);
#if DEBUG
    if (self._DANGEROUS_DISABLE_SSL_VERIFY) {
        PWarn(@"[DOH] !! DANGEROUS !! SSL peer verification disabled, this should only be used for unit tests");
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    }
#endif

    struct curl_slist *headers = NULL;
    headers = curl_slist_append(headers, "Accept: application/dns-message");
    headers = curl_slist_append(headers, "Content-Length: 0");

    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);

    curl_easy_setopt(curl, CURLOPT_PROTOCOLS, CURLPROTO_HTTPS);
    curl_easy_setopt(curl, CURLOPT_HTTP_CONTENT_DECODING, 0);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 0);
    curl_easy_setopt(curl, CURLOPT_TCP_NODELAY, 1);

    PDebug(@"[DOH] HTTP GET %@", url);
    CURLcode status = curl_easy_perform(curl);
    if (status != CURLE_OK) {
        PError(@"[DOH] Request error: %s (%i)", curl_easy_strerror(status), status);
        NSError * error;

        if (status == CURLE_COULDNT_CONNECT) {
            NSString * errorMsg = [NSString stringWithUTF8String:curl_easy_strerror(status)];
            error = MAKE_ERROR(1, errorMsg);
        } else if (status == CURLE_WRITE_ERROR) {
            PError(@"[DOH] content length exeeced limit. Limit=512 Length=%lu", contentLength);
            error = MAKE_ERROR(1, @"Response exceeds maximum length");
        } else {
            long response_code;
            curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);

            PError(@"[DOH] HTTP Response: %ld", response_code);
            PDebug(@"[DOH] HTTP %@ response %ld", url, response_code);
            NSString * errorDesc = [NSString stringWithFormat:@"HTTP Error %ld", response_code];
            error = MAKE_ERROR(1, errorDesc);
        }

        curl_easy_cleanup(curl);
        free(curldata.response);
        completed(nil, error);
        return;
    }
    if (curldata.size == 0) {
        PError(@"[DOH] Empty response for dns request");
        PDebug(@"[DOH] HTTP %@ empty response", url);
        curl_easy_cleanup(curl);
        free(curldata.response);
        completed(nil, MAKE_ERROR(1, @"Empty HTTP response"));
        return;
    }
    struct curl_header *contentType;
    if (curl_easy_header(curl, "Content-Type", 0, CURLH_HEADER, -1, &contentType) != CURLHE_OK) {
        PError(@"[DOH] No content type header found on dns response");
        curl_easy_cleanup(curl);
        free(curldata.response);
        completed(nil, MAKE_ERROR(1, @"Missing content type in response"));
        return;
    }
    if (![[[NSString stringWithUTF8String:contentType->value] lowercaseString] isEqualToString:@"application/dns-message"]) {
        PError(@"[DOH] Invalid content type for dns response: %s", contentType->value);
        curl_easy_cleanup(curl);
        free(curldata.response);
        completed(nil, MAKE_ERROR(1, @"Invalid content type in response"));
        return;
    }

    curl_easy_cleanup(curl);

    PDebug(@"[DOH] HTTP Response: 200");
    NSData * responseBytes = [NSData dataWithBytes:curldata.response length:curldata.size];
    free(curldata.response);
    PDebug(@"[DOH] Response %@", [responseBytes hexString]);

    PDebug(@"[DOH] reading %lu bytes for header", sizeof(DNS_HEADER));
    NSData * headerBytes = [responseBytes subdataWithRange:NSMakeRange(0, sizeof(DNS_HEADER))];
    DNS_HEADER * responseHeader = (DNS_HEADER *)headerBytes.bytes;
    uint16_t responseId = responseHeader->idn;
    uint16_t responseIdH = ntohs(responseId);
    if (responseId != idn && responseIdH != idn) {
        PError(@"[DOH] Response ID %i / %i does not match request ID %i", responseId, responseIdH, idn);
        completed(nil, MAKE_ERROR(1, @"Bad response ID"));
        return;
    }

    CKDNSResponseCode rcode = (CKDNSResponseCode)responseHeader->rcode;
    PDebug(@"[DOH] Response code %i", (int)rcode);
    if (rcode != CKDNSResponseCodeSuccess) {
        PError(@"[DOH] Bad response code: %i", responseHeader->rcode);
        CKDNSResult * result = [CKDNSResult new];
        result.responseCode = rcode;
        completed(result, MAKE_ERROR(1, @"Bad response code"));
        return;
    }

    short questionCount = ntohs(responseHeader->qlen);
    if (questionCount != 1) {
        PError(@"[DOH] Unexpected number of questions returned in DNS response: %i", questionCount);
        completed(nil, MAKE_ERROR(1, @"Unexpected number of questions in DNS response"));
        return;
    }
    short answerCount = ntohs(responseHeader->alen);
    if (answerCount == 0) {
        PError(@"[DOH] Unexpected number of answers returned in DNS response: %i", answerCount);
        completed(nil, MAKE_ERROR(1, @"No answers in DNS response"));
        return;
    }

    NSUInteger answerStart = [self getStartOfAnswerFromReply:responseBytes];
    PDebug(@"[DOH] Jumping to offset %i", (int)answerStart);
    int segmentStartIdx = (int)answerStart;

    NSMutableArray<CKDNSResource *> * resources = [NSMutableArray new];
    int answersRead = 0;
    while (answersRead < answerCount) {
        NSError * nameError;
        int dataIndex;
        NSString * name = [self readDNSName:responseBytes startIndex:segmentStartIdx dataIndex:&dataIndex error:&nameError];
        PDebug(@"[DOH] Answer data starts at offset %i", dataIndex);

        if (nameError != nil) {
            PError(@"[DOH] Invalid DNS name in response: %@", nameError.localizedDescription);
            completed(nil, MAKE_ERROR(1, @"Bad response"));
            return;
        }
        if (dataIndex+10 > responseBytes.length-1) {
            PError(@"[DOH] Incomplete DNS response");
            completed(nil, MAKE_ERROR(1, @"Bad response"));
            return;
        }

        uint16_t rtype = ntohs(*(uint16_t *)[responseBytes subdataWithRange:NSMakeRange(dataIndex, 2)].bytes);
        uint16_t rclass = ntohs(*(uint16_t *)[responseBytes subdataWithRange:NSMakeRange(dataIndex+2, 2)].bytes);
        // skip ttl, we don't read it since we don't cache responses
        uint16_t dlen = ntohs(*(uint16_t *)[responseBytes subdataWithRange:NSMakeRange(dataIndex+8, 2)].bytes);

        if (rclass != 1) {
            PError(@"[DOH] Unsupported resource class %i", rclass);
            completed(nil, MAKE_ERROR(1, @"Bad resource class in DNS response"));
            return;
        }

        if (dlen == 0) {
            PError(@"[DOH] Empty DNS response");
            completed(nil, MAKE_ERROR(1, @"Empty data in DNS response"));
            return;
        }
        if (dataIndex+10+dlen > responseBytes.length) {
            PError(@"[DOH] Data length %i exceeds response bytes %lu", dlen, (unsigned long)responseBytes.length);
            completed(nil, MAKE_ERROR(1, @"Bad response"));
            return;
        }

        NSData * value = [responseBytes subdataWithRange:NSMakeRange(dataIndex+10, dlen)];
        PDebug(@"[DOH] Answer data %@", [value hexString]);
        PDebug(@"[DOH] Data length %i", dlen);
        segmentStartIdx = dataIndex+10+dlen;

        switch ((CKDNSRecordType)rtype) {
            case CKDNSRecordTypeA:
            case CKDNSRecordTypeAAAA: {
                int addrlen = (CKDNSRecordType)rtype == CKDNSRecordTypeA ? INET_ADDRSTRLEN : INET6_ADDRSTRLEN;
                int af = (CKDNSRecordType)rtype == CKDNSRecordTypeA ? AF_INET : AF_INET6;
                char * addr = malloc(addrlen);
                inet_ntop(af, value.bytes, addr, addrlen);
                CKDNSResource * resource = [CKDNSResource new];
                resource.name = name;
                resource.recordType = (CKDNSRecordType)rtype;
                resource.value = [NSString stringWithFormat:@"%s", addr];
                [resources addObject:resource];
                break;
            } case CKDNSRecordTypeCNAME: {
                PDebug(@"[DOH] Answer for %@ is a CNAME", name);
                NSError * valueError;
                NSString * nextName = [self readDNSName:responseBytes startIndex:dataIndex+10 dataIndex:NULL error:&valueError];
                if (valueError != nil) {
                    PError(@"[DOH] Bad CNAME value: %@", valueError);
                    completed(nil, MAKE_ERROR(1, @"Bad response"));
                    return;
                }
                CKDNSResource * resource = [CKDNSResource new];
                resource.name = name;
                resource.recordType = (CKDNSRecordType)rtype;
                resource.value = nextName;
                [resources addObject:resource];
                break;
            } default: {
                PDebug(@"[DOH] Skipping unknown or unsupported resource record type %i", rtype);
                break;
            }
        }

        answersRead++;
    }

    CKDNSResult * answer = [CKDNSResult new];
    answer.responseCode = rcode;
    answer.resources = resources;
    completed(answer, nil);
    return;
}

- (NSData *) requestFor:(NSString *)query type:(CKDNSRecordType)recordType idn:(uint16_t)idn withError:(NSError **)error {
    NSMutableData * request = [NSMutableData new];

    DNS_HEADER header;

    header.idn = htons(idn);
    header.rd = 1;
    header.tc = 0;
    header.aa = 0;
    header.opcode = 0;
    header.qr = 0;
    header.rcode = 0;
    header.cd = 0;
    header.ad = 0;
    header.z = 0;
    header.ra = 0;
    header.qlen = htons(1);
    header.alen = 0;
    header.aulen = 0;
    header.adlen = 0;

    [request appendBytes:&header length:sizeof(DNS_HEADER)];

    NSError * nameError;
    NSData * nameBytes = [self stringToDNSName:query error:&nameError];
    if (nameError != nil) {
        *error = nameError;
        return nil;
    }
    [request appendData:nameBytes];

    uint16_t qtype = htons(recordType);
    [request appendBytes:&qtype length:2];
    uint16_t qclass = htons(1);
    [request appendBytes:&qclass length:2];

    PDebug(@"[DOH] %lu %@ %@", recordType, query, [request hexString]);

    return request;
}

/// Converts 'www.example.com.' to [3]www[7]example[3]com[0]. Expects that name has the trailing '.'
- (NSData *) stringToDNSName:(NSString *)name error:(NSError **)error {
    NSMutableData * request = [NSMutableData new];

    NSArray<NSString *> * labels = [name componentsSeparatedByString:@"."];
    for (NSString * label in labels) {
        if (label.length > 63) {
            *error = MAKE_ERROR(500, @"Host name is too long");
            return nil;
        }

        char len = (short)label.length;
        [request appendBytes:&len length:1];
        if (label.length > 0) {
            [request appendData:[label dataUsingEncoding:NSASCIIStringEncoding]];
        }
    }

    return request;
}

/// Return the offset for which the answer begins in a DNS reply.
- (NSUInteger) getStartOfAnswerFromReply:(NSData *)reply  {
    // We've already validated the headers value, so jump to the end of it
    int offset = sizeof(DNS_HEADER);

    // DNS compression doesn't explicitly require that the uncompressed name be the first occurance of it in the reply
    // so we can't assume that the length of the question in the reply will match the length of the question
    // we sent to the server.
    //
    // We're not using readDNSName here since we're not actually concerned about consuming name, we just need to get past it to find the
    // end of the question and the start of the answer.
    bool finishedReadingName = false;
    while (!finishedReadingName) {
        NSUInteger length = [reply byteAtIndex:offset];
        if ((length & (1 << 7)) || length == 0) {
            // Is a pointer
            finishedReadingName = true;
            offset++;
        } else {
            // Is length
            offset += length + 1;
        }
    }

    offset += 4; // skip past qtype and qclass;
    return offset;
}

// Converts [3]www[7]example[3]com[0] to 'www.example.com.', supporting compression.
// If dataIndex is provided, it will be set to the offset of whatever data comes after this name
- (NSString *) readDNSName:(NSData *)data startIndex:(int)startIdx dataIndex:(int *)dataIndex error:(NSError **)error {
    NSMutableString * name = [NSMutableString new];
    short offset = startIdx;

    // DNS compression can apply to the entire name or individual lables, so check for pointers at each label
    while (true) {
        PDebug(@"[DOH] Read byte %i", offset);
        short ptrFlag = [data byteAtIndex:offset];
        if (ptrFlag == 0) {
            break;
        }

        if (ptrFlag & (1 << 7)) {
            PDebug(@"[DOH] Byte is pointer");
            if (dataIndex != NULL) {
                *dataIndex = startIdx+2;
            }

            short nextOffset = offset;
            int depth = 0;
            // Continue to follow pointers until we get to a length
            while (ptrFlag & (1 << 7)) {
                PDebug(@"[DOH] Byte is pointer");
                // DNS pointers can refer to another pointer, limit to a recursion depth of 10
                if (depth > 10) {
                    PError(@"[DOH] Maximum pointer depth exceeded");
                    *error = MAKE_ERROR(1, @"Bad response");
                    return nil;
                }

                PDebug(@"[DOH] Read byte %i", offset+1);
                nextOffset = [data byteAtIndex:offset+1];
                if (nextOffset > data.length-1) {
                    PError(@"[DOH] Offset %i exceeds data length %lu", nextOffset, (unsigned long)data.length);
                    *error = MAKE_ERROR(1, @"Bad response");
                    return nil;
                }

                PDebug(@"[DOH] Pointer destination is offset %i", nextOffset);
                PDebug(@"[DOH] Read byte %i", nextOffset);
                ptrFlag = [data byteAtIndex:nextOffset];
                depth++;
            }
            PDebug(@"[DOH] Byte is length");
            offset = nextOffset;
        }

        if (offset > data.length) {
            PError(@"[DOH] Offset %i exceeds data length %lu", offset, (unsigned long)data.length);
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }

        PDebug(@"[DOH] Read byte %i", offset);
        short len = [data byteAtIndex:offset];
        offset++;

        if (offset+len > data.length-1) {
            PError(@"[DOH] Bad length %i or offset %i", len, offset);
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }

        NSString * label = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(offset, len)] encoding:NSASCIIStringEncoding];
        PDebug(@"[DOH] Label length %i at offset %i: %@", len, offset, label);
        offset += len;

        // Reject labels that contain '.', as these are implied as separators to labels
        if ([label containsString:@"."]) {
            PDebug(@"[DOH] Invalid characters in label %@", label);
            *error = MAKE_ERROR(1, @"Bad response");
            return nil;
        }

        [name appendFormat:@"%@.", label];
    }
    if (dataIndex != NULL && *dataIndex == 0) {
        *dataIndex = (int)name.length;
    }

    return name;
}

- (CKDNSRecordType) getPreferredRecordTypeWithError:(NSError **)error {
    struct addrinfo hints;
    struct addrinfo *result;
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;
    hints.ai_flags = 0;
    hints.ai_protocol = 0;
    const char * query = "dns.google.";
    if (getaddrinfo(query, NULL, &hints, &result) != 0) {
        *error = MAKE_ERROR(1, @"Lookup error");
        return -1;
    }

    switch (result->ai_family) {
        case AF_INET:
            return CKDNSRecordTypeA;
        case AF_INET6:
            return CKDNSRecordTypeAAAA;
    }

    *error = MAKE_ERROR(1, @"Unknown record type");
    return -1;
}

size_t curl_doh_header_callback(char *buffer, size_t size, size_t nitems, void *userdata) {
    unsigned long * contentLength = (unsigned long *)userdata;
    unsigned long len = nitems * size;
    if (len > 2) {
        NSData * data = [NSData dataWithBytes:buffer length:len - 2]; // Trim the \r\n from the end of the header
        NSString * fullHeader = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray<NSString *> * headerComponents = [fullHeader splitFirst:@": "];
        if (headerComponents.count != 2) {
            return len;
        }
        NSString * headerKey = headerComponents[0].lowercaseString;
        NSString * headerValue = headerComponents[1];

        if ([headerKey isEqualToString:@"content-length"]) {
            NSNumberFormatter * formatter = [NSNumberFormatter new];
            unsigned long cl = [formatter numberFromString:headerValue].unsignedLongValue;
            if (cl > 512) { // RFC 1035
                *contentLength = cl;
                return 0;
            }
        }
    }
    return len;
}

size_t curl_doh_write_callback(void * data, size_t size, size_t nmemb, void * userp) {
    size_t realsize = size * nmemb;
    HTTP_RESPONSE * block = (HTTP_RESPONSE *)userp;
    PDebug(@"[DOH] write callback: realsize=%lu blockSize=%lu", realsize, block->size);

    char * ptr = realloc(block->response, block->size + realsize + 1);
    if (ptr == NULL) {
        PError(@"[DOH] unable to realloc response memory during write callback");
        return 0;
    }

    block->response = ptr;
    memcpy(&(block->response[block->size]), data, realsize);
    block->size += realsize;
    block->response[block->size] = 0;

    return realsize;
}

@end
