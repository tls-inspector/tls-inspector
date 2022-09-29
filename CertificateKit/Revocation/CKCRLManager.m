//
//  CKCRLManager.m
//
//  LGPLv3
//
//  Copyright (c) 2017 Ian Spence
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

#import "CKCRLManager.h"
#import "CKCurlCommon.h"
#import <openssl/err.h>
#import <openssl/x509.h>
#import <openssl/x509v3.h>
#import <curl/curl.h>
#import "NSDate+ASN1_TIME.h"

@interface CKCRLManager () {
    dispatch_queue_t queue;
}

@end

@implementation CKCRLManager

static CKCRLManager * _instance;

struct httpResponseBlock {
    char * response;
    size_t size;
};

#define CRL_MAX_SIZE_EXT 5 * (1024 * 1024)
#define CRL_MAX_SIZE_APP 20 * (1024 * 1024)
#define IS_EXTENSION ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.ecnepsnai.Certificate-Inspector.Inspect-Website"])

#define CRL_ERROR_CURL_LIBRARY -1
#define CRL_ERROR_HTTP_ERROR -2
#define CRL_ERROR_DECODE_ERROR -3
#define CRL_ERROR_CRL_ERROR -4
#define CRL_ERROR_NO_BODY -5
#define CRL_ERROR_TOO_LARGE -6

+ (CKCRLManager * _Nonnull) sharedManager {
    if (!_instance) {
        _instance = [CKCRLManager new];
    }
    return _instance;
}

- (id _Nonnull) init {
    if (!_instance) {
        _instance = [super init];
    }
    return _instance;
}

- (void) queryCertificate:(CKCertificate *)certificate issuer:(CKCertificate *)issuer response:(CKCRLResponse **)rtResponse error:(NSError **)rtError {
    if (certificate.crlDistributionPoints.count <= 0) {
        return;
    }

    NSURL * crlURL = certificate.crlDistributionPoints[0];
    
    NSError * crlError;
    X509_CRL * crl;
    [self getCRL:crlURL response:&crl error:&crlError];
    if (crlError != nil) {
        *rtError = crlError;
        return;
    }
    
    EVP_PKEY * issuerKey = X509_get_pubkey(issuer.X509Certificate);
    
    int rv;
    if ((rv = X509_CRL_verify(crl, issuerKey)) != 1) {
        // CRL Verification failure
        *rtError = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_CRL_ERROR userInfo:@{NSLocalizedDescriptionKey: @"CRL verification failed"}];
        PError(@"CRL verification error");
        return;
    }
    
    CKCRLResponse * crlResponse = [CKCRLResponse new];
    *rtResponse = crlResponse;
    
    X509_REVOKED * revoked;
    rv = X509_CRL_get0_by_cert(crl, &revoked, certificate.X509Certificate);
    if (rv > 0) {
        // Certificate is revoked
        PDebug(@"CRL Status: Revoked");
        crlResponse.status = CKCRLResponseStatusRevoked;
        const ASN1_TIME * revokedTime = X509_REVOKED_get0_revocationDate(revoked);
        crlResponse.revokedOn = [NSDate fromASN1_TIME:revokedTime];
        
        ASN1_ENUMERATED *reasonASN;
        reasonASN = X509_REVOKED_get_ext_d2i(revoked, NID_crl_reason, NULL, NULL);
        long reason = ASN1_ENUMERATED_get(reasonASN);
        crlResponse.reason = reason;
        crlResponse.reasonString = [self reasonString:reason];
    } else if (rv == 0) {
        // Certificate not found
        PDebug(@"CRL Status: Not Found");
        crlResponse.status = CKCRLResponseStatusNotFound;
    } else {
        // CRL parsing failure
        PDebug(@"CRL Status: Unknown");
        *rtError = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_CRL_ERROR userInfo:@{NSLocalizedDescriptionKey: @"CRL parsing failed"}];
        return;
    }
    X509_CRL_free(crl);
}

- (void) getCRL:(NSURL *)url response:(X509_CRL **)crlResponse error:(NSError **)error {
    CURL * curl = [[CKCurlCommon sharedInstance] curlHandle];
    if (!curl) {
        *error = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_CURL_LIBRARY userInfo:@{NSLocalizedDescriptionKey: @"Error initalizing CURL library"}];
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
    struct httpResponseBlock curldata;
    curldata.response = malloc(0);
    curldata.size = 0;
    curl_easy_setopt(curl, CURLOPT_URL, url.absoluteString.UTF8String);
    curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, crl_header_callback);
    curl_easy_setopt(curl, CURLOPT_HEADERDATA, &contentLength);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, crl_write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&curldata);
    
    struct curl_slist *headers = NULL;
    headers = curl_slist_append(headers, "Accept: application/pkix-crl");
    
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);
    
    curl_easy_setopt(curl, CURLOPT_PROTOCOLS, CURLPROTO_HTTP);
    curl_easy_setopt(curl, CURLOPT_HTTP_CONTENT_DECODING, 0);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 0);
    curl_easy_setopt(curl, CURLOPT_TCP_NODELAY, 1);
    
    PDebug(@"CRL HTTP GET %@", url.absoluteString);
    
    CURLcode response = curl_easy_perform(curl);
    if (response != CURLE_OK) {
        PError(@"CRL Request error: %s (%i)", curl_easy_strerror(response), response);

        // ContentLength is only set if we rejected this response because it was too large
        if (contentLength > 0) {
            PError(@"CRL content length exeeced limit. AppLimit=%i ExtLimit=%i Length=%lu", CRL_MAX_SIZE_APP, CRL_MAX_SIZE_EXT, contentLength);
            *error = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_TOO_LARGE userInfo:@{NSLocalizedDescriptionKey: @"CRL too large"}];
        } else {
            long response_code;
            curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);

            *error = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_HTTP_ERROR userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Error %ld", response_code]}];
            PError(@"CRL HTTP Response: %ld", response_code);
            PDebug(@"CRL HTTP %@ response %ld", url.absoluteString, response_code);
        }

        curl_easy_cleanup(curl);
        free(curldata.response);
        return;
    }
    if (curldata.size == 0) {
        PError(@"Empty response for CRL request");
        PDebug(@"CRL HTTP %@ empty response", url.absoluteString);
        *error = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_NO_BODY userInfo:@{NSLocalizedDescriptionKey: @"Empty CRL response"}];
        curl_easy_cleanup(curl);
        free(curldata.response);
        return;
    }
    
    PDebug(@"CRL HTTP Response: 200");
    
    X509_CRL * crl = NULL;
    crl = d2i_X509_CRL(NULL, (const unsigned char **)&curldata.response, curldata.size);
    if (crl == NULL) {
        [self openSSLError];
        *error = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_HTTP_ERROR userInfo:@{NSLocalizedDescriptionKey: @"Error decoding CRL response"}];
        PError(@"Error decoding CRL response");
        return;
    }
    *crlResponse = crl;
    curl_easy_cleanup(curl);

    // Dump curls output to the log file
    if (CKLogging.sharedInstance.level == CKLoggingLevelDebug) {
        fflush(curlout);
        fclose(curlout);
        PDebug(@"curl output:\n%s", buf);
        free(buf);
    }

    return;
}

size_t crl_header_callback(char *buffer, size_t size, size_t nitems, void *userdata) {
    unsigned long * contentLength = (unsigned long *)userdata;
    unsigned long len = nitems * size;
    if (len > 2) {
        NSData * data = [NSData dataWithBytes:buffer length:len - 2]; // Trim the \r\n from the end of the header
        NSString * headerValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray<NSString *> * components = [headerValue.lowercaseString componentsSeparatedByString:@": "];
        if (components.count < 2) {
            return len;
        }
        if ([components[0] isEqualToString:@"content-length"]) {
            NSNumberFormatter * formatter = [NSNumberFormatter new];
            unsigned long cl = [formatter numberFromString:components[1]].unsignedLongValue;
            if (IS_EXTENSION && cl > CRL_MAX_SIZE_EXT) {
                *contentLength = cl;
                return 0;
            } else if (!IS_EXTENSION && cl > CRL_MAX_SIZE_APP) {
                *contentLength = cl;
                return 0;
            }
        }
    }
    return len;
}

size_t crl_write_callback(void * data, size_t size, size_t nmemb, void * userp) {
    size_t realsize = size * nmemb;
    struct httpResponseBlock *block = (struct httpResponseBlock *)userp;
    PDebug(@"CRL write callback: realsize=%lu blockSize=%lu", realsize, block->size);

    char * ptr = realloc(block->response, block->size + realsize + 1);
    if (ptr == NULL) {
        PError(@"CRL unable to realloc response memory during write callback");
        return 0;
    }

    block->response = ptr;
    memcpy(&(block->response[block->size]), data, realsize);
    block->size += realsize;
    block->response[block->size] = 0;

    return realsize;
}

- (NSString *) reasonString:(long)reason {
    switch (reason) {
        case CRL_REASON_NONE:
            return @"None";
        case CRL_REASON_UNSPECIFIED:
            return @"Unspecified";
        case CRL_REASON_KEY_COMPROMISE:
            return @"Key compromise";
        case CRL_REASON_CA_COMPROMISE:
            return @"CA compromise";
        case CRL_REASON_AFFILIATION_CHANGED:
            return @"Affiliation changed";
        case CRL_REASON_SUPERSEDED:
            return @"Superseded";
        case CRL_REASON_CESSATION_OF_OPERATION:
            return @"Cessation of operation";
        case CRL_REASON_CERTIFICATE_HOLD:
            return @"Certificate hold";
        case CRL_REASON_REMOVE_FROM_CRL:
            return @"Remove from CRL";
        case CRL_REASON_PRIVILEGE_WITHDRAWN:
            return @"Privilege withdrawn";
        case CRL_REASON_AA_COMPROMISE:
            return @"AA compromise";
        default:
            return @"Unknown";
    }
}

INSERT_OPENSSL_ERROR_METHOD

@end
