//
//  CKCertificateChain+EnumValues.m
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

#import "CKCertificateChain+EnumValues.h"
#import <openssl/ssl.h>

@implementation CKCertificateChain (EnumValues)

- (NSString *) protocolString {
    switch (self.protocol) {
        case TLS1_3_VERSION:
            return @"TLS 1.3";
            break;
        case TLS1_2_VERSION:
            return @"TLS 1.2";
            break;
        case TLS1_1_VERSION:
            return @"TLS 1.1";
            break;
        case TLS1_VERSION:
            return @"TLS 1.0";
        case SSL3_VERSION:
            return @"SSL 3.0";
            break;
        case SSL2_VERSION:
            return @"SSL 2.0";
            break;
        default:
            return @"Unknown";
            break;
    }

    return @"Unknown";
}

@end
