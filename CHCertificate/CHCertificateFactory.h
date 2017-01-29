//
//  CHCertificateFactory.h
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
//  https://github.com/ecnepsnai/CHCertificate
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

#import <Foundation/Foundation.h>
#import "CHCertificate.h"

@interface CHCertificateFactory : NSObject

/**
 *  Query the specified URL for its certificate chain.
 *
 *  @param URL      The URL to query. Must use the https scheme.
 *                  The port is optional and will default to 443.
 *  @param finished Called when finished with either an error or certificates.
 */
- (void) certificateChainFromURL:(NSURL *)URL finished:(void (^)(NSError * error,
                                                                 NSArray<CHCertificate *> * certificates,
                                                                 BOOL trustedChain))finished;

@end
