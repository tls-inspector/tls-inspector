//
//  CKOCSPManager.m
//
//  MIT License
//
//  Copyright (c) 2018 Ian Spence
//  https://github.com/certificate-helper/CertificateKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "CKOCSPManager.h"
#import <openssl/x509.h>
#import <openssl/ocsp.h>
#import <curl/curl.h>

@interface CKOCSPManager ()

@property (strong, nonatomic) NSMutableData * responseDataBuffer;

@end

@implementation CKOCSPManager

static CKOCSPManager * _instance;

+ (CKOCSPManager *) sharedManager {
    if (_instance != nil) {
        return _instance;
    }

    return [CKOCSPManager new];
}

- (instancetype) init {
    if (_instance == nil) {
        _instance = [super init];
    }
    return _instance;
}

#define HASH_ALGORITM_SIZE 11

- (void) queryCertificate:(CKCertificate *)certificate issuer:(CKCertificate *)issuer finished:(void (^)(NSError *))finished {
    NSURL * ocspURL = certificate.ocspURL;
    
    OCSP_CERTID * certID = OCSP_cert_to_id(NULL, certificate.X509Certificate, issuer.X509Certificate);
    NSData * request = [self generateOCSPRequestForCertificate:certID];
    
    OCSP_BASICRESP * resp = [self queryOCSPResponder:ocspURL withRequest:request];
    
    int status;
    int reason;
    ASN1_GENERALIZEDTIME * time;
    ASN1_GENERALIZEDTIME * thisUP;
    ASN1_GENERALIZEDTIME * nextUP;
    int rt = OCSP_resp_find_status(resp, certID, &status, &reason, &time, &thisUP, &nextUP);
    NSLog(@"rt: %i", rt);
}

- (NSData *) generateOCSPRequestForCertificate:(OCSP_CERTID *)certid {
    OCSP_REQUEST * request = OCSP_REQUEST_new();
    OCSP_request_add0_id(request, certid);
    unsigned char * request_data = NULL;
    int len = i2d_OCSP_REQUEST(request, &request_data);
    return [[NSData alloc] initWithBytes:request_data length:len];
}

- (OCSP_RESPONSE *) decodeResponse:(NSData *)data {
    const unsigned char * bytes = [data bytes];
    OCSP_RESPONSE * response = d2i_OCSP_RESPONSE(NULL, &bytes, data.length);
    return response;
}

- (OCSP_BASICRESP *) queryOCSPResponder:(NSURL *)responder withRequest:(NSData *)request {
    CURL * curl;
    CURLcode response;

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
    if (!curl) {
        // Error
    }

#ifdef DEBUG
    curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
#endif

    self.responseDataBuffer = [NSMutableData new];
    
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString * version = infoDictionary[@"CFBundleShortVersionString"];
    NSString * userAgent = [NSString stringWithFormat:@"CertificateKit TLS-Inspector/%@ +https://tlsinspector.com/", version];

    curl_easy_setopt(curl, CURLOPT_URL, responder.absoluteString.UTF8String);
    curl_easy_setopt(curl, CURLOPT_USERAGENT, userAgent.UTF8String);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, ocsp_write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, self.responseDataBuffer);

    struct curl_slist *headers = NULL;
    headers = curl_slist_append(headers, "Content-Type: application/ocsp-request");

    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, request.bytes);

    response = curl_easy_perform(curl);
    if (response != CURLE_OK) {
        NSLog(@"CURL ERROR!");
    }
    
    OCSP_RESPONSE * ocspResponse = [self decodeResponse:self.responseDataBuffer];
    return OCSP_response_get1_basic(ocspResponse);
}

size_t ocsp_write_callback(void *buffer, size_t size, size_t nmemb, void *userp) {
    [((__bridge NSMutableData *)userp) appendBytes:buffer length:size * nmemb];
    return size * nmemb;
}

@end
