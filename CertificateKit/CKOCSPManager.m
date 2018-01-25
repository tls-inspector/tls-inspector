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

- (void) queryCertificate:(CKCertificate *)certificate finished:(void (^)(NSError *))finished {
    // Since we don't know whether the OCSP responder supports anything other
    // than SHA-1, we have no choice but to use SHA-1 for issuerNameHash and
    // issuerKeyHash.
    static const uint8_t hashAlgorithm[11] = {
        0x30, 0x09,                               // SEQUENCE
        0x06, 0x05, 0x2B, 0x0E, 0x03, 0x02, 0x1A, //   OBJECT IDENTIFIER id-sha1
        0x05, 0x00,                               //   NULL
    };
    static const uint8_t hashLen = 160 / 8;

    static const unsigned int totalLenWithoutSerialNumberData
    = 2                             // OCSPRequest
    + 2                             //   tbsRequest
    + 2                             //     requestList
    + 2                             //       Request
    + 2                             //         reqCert (CertID)
    + sizeof(hashAlgorithm)         //           hashAlgorithm
    + 2 + hashLen                   //           issuerNameHash
    + 2 + hashLen                   //           issuerKeyHash
    + 2;                            //           serialNumber (header)

    // The only way we could have a request this large is if the serialNumber was
    // ridiculously and unreasonably large. RFC 5280 says "Conforming CAs MUST
    // NOT use serialNumber values longer than 20 octets." With this restriction,
    // we allow for some amount of non-conformance with that requirement while
    // still ensuring we can encode the length values in the ASN.1 TLV structures
    // in a single byte.
    NSAssert(totalLenWithoutSerialNumberData < OCSP_REQUEST_MAX_LENGTH, @"totalLenWithoutSerialNumberData too big");
    if (certificate.serialNumber.length > OCSP_REQUEST_MAX_LENGTH - totalLenWithoutSerialNumberData) {
        finished([NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @""}]);
        return;
    }

    size_t outLen = totalLenWithoutSerialNumberData + certificate.serialNumber.length;
    uint8_t totalLen = (uint8_t)outLen;

    uint8_t * out;
    uint8_t* d = out;
    *d++ = 0x30; *d++ = totalLen - 2u;  // OCSPRequest (SEQUENCE)
    *d++ = 0x30; *d++ = totalLen - 4u;  //   tbsRequest (SEQUENCE)
    *d++ = 0x30; *d++ = totalLen - 6u;  //     requestList (SEQUENCE OF)
    *d++ = 0x30; *d++ = totalLen - 8u;  //       Request (SEQUENCE)
    *d++ = 0x30; *d++ = totalLen - 10u; //         reqCert (CertID SEQUENCE)

    // reqCert.hashAlgorithm
    for (const uint8_t hashAlgorithmByte : hashAlgorithm) {
        *d++ = hashAlgorithmByte;
    }
}

@end
