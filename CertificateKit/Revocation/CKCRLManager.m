//
//  CKCRLManager.m
//
//  MIT License
//
//  Copyright (c) 2017 Ian Spence
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

#import "CKCRLManager.h"
#import <openssl/err.h>
#import <openssl/x509.h>
#import <openssl/x509v3.h>
#import <curl/curl.h>
#import "NSDate+ASN1_TIME.h"

@interface CKCRLManager ()

@property (strong, nonatomic) NSMutableData * responseDataBuffer;

@end

@implementation CKCRLManager

#define CRL_ERROR_CURL_LIBRARY -1
#define CRL_ERROR_HTTP_ERROR -2
#define CRL_ERROR_DECODE_ERROR -3
#define CRL_ERROR_CRL_ERROR -4

static CKCRLManager * _instance;

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
    CURL * curl;
    
    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
    if (!curl) {
        *error = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_CURL_LIBRARY userInfo:@{NSLocalizedDescriptionKey: @"Error initalizing CURL library"}];
        return;
    }
    
#ifdef DEBUG
    curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
#endif
    
    self.responseDataBuffer = [NSMutableData new];
    
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString * version = infoDictionary[@"CFBundleShortVersionString"];
    NSString * userAgent = [NSString stringWithFormat:@"CertificateKit TLS-Inspector/%@ +https://tlsinspector.com/", version];
    
    curl_easy_setopt(curl, CURLOPT_URL, url.absoluteString.UTF8String);
    curl_easy_setopt(curl, CURLOPT_USERAGENT, userAgent.UTF8String);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, crl_write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, self.responseDataBuffer);
    
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
        long response_code;
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
        
        *error = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_HTTP_ERROR userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Error %ld", response_code]}];
        PError(@"CRL HTTP Response: %ld", response_code);
        
        curl_easy_cleanup(curl);
        return;
    }
    
    PDebug(@"CRL HTTP Response: 200");
    
    X509_CRL * crl = NULL;
    const unsigned char * bytes = self.responseDataBuffer.bytes;
    crl = d2i_X509_CRL(NULL, &bytes, self.responseDataBuffer.length);
    if (crl == NULL) {
        [self openSSLError];
        *error = [NSError errorWithDomain:@"CKCRLManager" code:CRL_ERROR_HTTP_ERROR userInfo:@{NSLocalizedDescriptionKey: @"Error decoding CRL response"}];
        PError(@"Error decoding CRL response");
    }
    *crlResponse = crl;
    curl_easy_cleanup(curl);
    return;
}

size_t crl_write_callback(void *buffer, size_t size, size_t nmemb, void *userp) {
    [((__bridge NSMutableData *)userp) appendBytes:buffer length:size * nmemb];
    return size * nmemb;
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
