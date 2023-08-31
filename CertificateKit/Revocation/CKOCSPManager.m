//
//  CKOCSPManager.m
//
//  LGPLv3
//
//  Copyright (c) 2018 Ian Spence
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

#import "CertificateKit.h"
#import "CKOCSPManager.h"
#import "CKCurlCommon.h"
#import "CKCertificate+Private.h"
#import "CKLogging+Private.h"
#import <openssl/x509.h>
#import <openssl/ocsp.h>
#import <curl/curl.h>
#import "NSString+SplitFirst.h"

@interface CKOCSPManager () {
    dispatch_queue_t queue;
}

@end

@implementation CKOCSPManager

static CKOCSPManager * _instance;

struct httpResponseBlock {
    char * response;
    size_t size;
};


#define OCSP_MAX_SIZE 5 * 1024 // 5KiB

#define OCSP_ERROR_INVALID_RESPONSE -1
#define OCSP_ERROR_CURL_LIBRARY -2
#define OCSP_ERROR_HTTP_ERROR -3
#define OCSP_ERROR_DECODE_ERROR -4
#define OCSP_ERROR_REQUEST_ERROR -5
#define OCSP_ERROR_NO_BODY -6
#define OCSP_ERROR_TOO_LARGE -7

+ (CKOCSPManager *) sharedManager {
    if (_instance != nil) {
        return _instance;
    }

    return [CKOCSPManager new];
}

- (instancetype) init {
    if (_instance == nil) {
        self = [super init];
        queue = dispatch_queue_create("com.tlsinspector.OCSPManager", NULL);
        _instance = self;
    }
    return _instance;
}

- (NSError *) queryCertificate:(CKCertificate *)certificate issuer:(CKCertificate *)issuer response:(CKOCSPResponse * __autoreleasing *)rtresponse {
    NSURL * ocspURL = certificate.ocspURL;
    if (ocspURL == nil) {
        return nil;
    }
    
    OCSP_CERTID * certID = OCSP_cert_to_id(NULL, certificate.X509Certificate, issuer.X509Certificate);
    PDebug(@"Querying OCSP for certificate: '%@'", certificate.subject.commonNames);
    OCSP_REQUEST * request = [self generateOCSPRequestForCertificate:certID];
    
    unsigned char * request_data = NULL;
    int len = i2d_OCSP_REQUEST(request, &request_data);
    if (len == 0) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        PError(@"Error getting ASN bytes from OCSP request object");
        return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_DECODE_ERROR userInfo:@{NSLocalizedDescriptionKey: @"Unable to create OCSP request"}];;
    }
    NSData * requestData = [[NSData alloc] initWithBytes:request_data length:len];
    
    OCSP_BASICRESP * resp;
    NSError * queryError = [self queryOCSPResponder:ocspURL withRequest:requestData resp:&resp];
    if (queryError != nil) {
        return queryError;
    }
    CKOCSPResponse * response = [CKOCSPResponse new];
    *rtresponse = response;
    
    if (queryError != nil) {
        if (queryError.code == OCSP_ERROR_REQUEST_ERROR) {
            response.status = CKOCSPResponseStatusUnknown;
            PDebug(@"OCSP request status: Unknown");
            return nil;
        }
        return queryError;
    }
    
    int status;
    int reason;
    ASN1_GENERALIZEDTIME * time;
    ASN1_GENERALIZEDTIME * thisUP;
    ASN1_GENERALIZEDTIME * nextUP;
    if (!OCSP_resp_find_status(resp, certID, &status, &reason, &time, &thisUP, &nextUP)) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        PError(@"Unable to find status in OCSP response");
        return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_INVALID_RESPONSE userInfo:@{NSLocalizedDescriptionKey: @"Invalid OCSP response."}];;
    }
    
    switch (status) {
        case V_OCSP_CERTSTATUS_GOOD:
            response.status = CKOCSPResponseStatusOK;
            PDebug(@"OCSP certificate status GOOD");
            break;
        case V_OCSP_CERTSTATUS_UNKNOWN:
            response.status = CKOCSPResponseStatusUnknown;
            PDebug(@"OCSP certificate status UNKNOWN");
            break;
        case V_OCSP_CERTSTATUS_REVOKED:
            response.status = CKOCSPResponseStatusRevoked;
            PDebug(@"OCSP certificate status REVOKED");
            response.reason = reason;
            break;
    }

    OCSP_REQUEST_free(request);
    OCSP_BASICRESP_free(resp);
    return nil;
}

- (OCSP_REQUEST *) generateOCSPRequestForCertificate:(OCSP_CERTID *)certid {
    OCSP_REQUEST * request = OCSP_REQUEST_new();
    OCSP_request_add0_id(request, certid);
    return request;
}

- (OCSP_RESPONSE *) decodeResponse:(NSData *)data {
    const unsigned char * bytes = [data bytes];
    OCSP_RESPONSE * response = d2i_OCSP_RESPONSE(NULL, &bytes, data.length);
    return response;
}

- (NSError *) queryOCSPResponder:(NSURL *)responder withRequest:(NSData *)request resp:(OCSP_BASICRESP **)resp {
    CURL * curl = [[CKCurlCommon sharedInstance] curlHandle];
    if (!curl) {
        PError(@"Error initalizing the CURL library. This shouldn't happen!");
        return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_CURL_LIBRARY userInfo:@{NSLocalizedDescriptionKey: @"Error initalizing CURL library"}];
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
    struct httpResponseBlock curldata;
    curldata.response = malloc(0);
    curldata.size = 0;
    curl_easy_setopt(curl, CURLOPT_URL, responder.absoluteString.UTF8String);
    curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, ocsp_header_callback);
    curl_easy_setopt(curl, CURLOPT_HEADERDATA, &contentLength);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, ocsp_write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&curldata);
    
    struct curl_slist *headers = NULL;
    headers = curl_slist_append(headers, "Content-Type: application/ocsp-request");
    headers = curl_slist_append(headers, "Accept: application/ocsp-response");
    
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, request.bytes);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, request.length);
    
    curl_easy_setopt(curl, CURLOPT_PROTOCOLS, CURLPROTO_HTTP);
    curl_easy_setopt(curl, CURLOPT_HTTP_CONTENT_DECODING, 0);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 0);
    curl_easy_setopt(curl, CURLOPT_TCP_NODELAY, 1);
    
    PDebug(@"OCSP Request: HTTP GET %@", responder.absoluteString);
    
    CURLcode response = curl_easy_perform(curl);
    if (response != CURLE_OK) {
        PError(@"OCSP Request error: %s (%i)", curl_easy_strerror(response), response);
        // ContentLength is only set if we rejected this response because it was too large
        if (contentLength > 0) {
            PError(@"OCSP content length exeeced limit. Limit=%i Length=%lu", OCSP_MAX_SIZE, contentLength);
            curl_easy_cleanup(curl);
            free(curldata.response);
            return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_TOO_LARGE userInfo:@{NSLocalizedDescriptionKey: @"OCSP too large"}];
        } else {
            long response_code;
            curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);

            PError(@"OCSP HTTP Response: %ld", response_code);
            PDebug(@"OCSP HTTP %@ response %ld", responder.absoluteString, response_code);

            curl_easy_cleanup(curl);
            free(curldata.response);
            return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_HTTP_ERROR userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Error %ld", response_code]}];
        }
    }
    if (curldata.size == 0) {
        PError(@"Empty response for OCSP request");
        PDebug(@"OCSP HTTP %@ empty response", responder.absoluteString);
        curl_easy_cleanup(curl);
        free(curldata.response);
        return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_NO_BODY userInfo:@{NSLocalizedDescriptionKey: @"Empty OCSP response"}];
    }

    struct curl_header *contentType;
    if (curl_easy_header(curl, "Content-Type", 0, CURLH_HEADER, -1, &contentType) != CURLHE_OK) {
        PError(@"No content type header found on OCSP response");
        curl_easy_cleanup(curl);
        free(curldata.response);
        return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_INVALID_RESPONSE userInfo:@{NSLocalizedDescriptionKey: @"Missing content type"}];
    }
    if (![[[NSString stringWithUTF8String:contentType->value] lowercaseString] isEqualToString:@"application/ocsp-response"]) {
        PError(@"Invalid content type for OCSP response %s", contentType->value);
        curl_easy_cleanup(curl);
        free(curldata.response);
        return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_INVALID_RESPONSE userInfo:@{NSLocalizedDescriptionKey: @"Invalid content type"}];
    }
    
    PDebug(@"OCSP HTTP Response: 200");
    OCSP_RESPONSE * ocspResponse = [self decodeResponse:[[NSData alloc] initWithBytes:curldata.response length:curldata.size]];
    free(curldata.response);
    if (ocspResponse == NULL) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        PError(@"Error decoding OCSP response");
        return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_DECODE_ERROR userInfo:@{NSLocalizedDescriptionKey: @"Error decoding OCSP response."}];;
    }
    int requestResponse = OCSP_response_status(ocspResponse);
    if (requestResponse != OCSP_RESPONSE_STATUS_SUCCESSFUL) {
        PError(@"OCSP Response status: %i", requestResponse);
        return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_REQUEST_ERROR userInfo:@{NSLocalizedDescriptionKey: @"OCSP request error."}];;
    }
    
    OCSP_BASICRESP * basicResp = OCSP_response_get1_basic(ocspResponse);
    if (basicResp == NULL) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        PError(@"Error getting basic OCSP response from OCSP response object");
        return [NSError errorWithDomain:@"CKOCSPManager" code:OCSP_ERROR_DECODE_ERROR userInfo:@{NSLocalizedDescriptionKey: @"Error decoding OCSP response."}];;
    }
    
    *resp = basicResp;
    
    curl_easy_cleanup(curl);

    // Dump curls output to the log file
    if (CKLogging.sharedInstance.level == CKLoggingLevelDebug) {
        fflush(curlout);
        fclose(curlout);
        PDebug(@"curl output:\n%s", buf);
        free(buf);
    }

    return nil;
}

size_t ocsp_header_callback(char *buffer, size_t size, size_t nitems, void *userdata) {
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
            if (cl > OCSP_MAX_SIZE) {
                *contentLength = cl;
                return 0;
            }
        }
    }
    return len;
}

size_t ocsp_write_callback(void * data, size_t size, size_t nmemb, void * userp) {
    size_t realsize = size * nmemb;
    struct httpResponseBlock *block = (struct httpResponseBlock *)userp;
    PDebug(@"OCSP write callback: realsize=%lu blockSize=%lu", realsize, block->size);

    char * ptr = realloc(block->response, block->size + realsize + 1);
    if (ptr == NULL) {
        PError(@"OCSP unable to realloc response memory during write callback");
        return 0;
    }

    block->response = ptr;
    memcpy(&(block->response[block->size]), data, realsize);
    block->size += realsize;
    block->response[block->size] = 0;

    return realsize;
}

@end
