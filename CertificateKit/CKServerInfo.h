//
//  CKServerInfo.h
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

#import <Foundation/Foundation.h>

/**
 CKServerInfo is a interface containing information about a HTTPS protected server
 */
@interface CKServerInfo : NSObject

/**
 A dictionary of all response headers recieved when querying the domain
 */
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> * headers;
/**
 A dictionary of all security response headers mapped to a (NSNumber)BOOL of if the header was present
 */
@property (strong, nonatomic) NSDictionary<NSString *, id> * securityHeaders;
/**
 The HTTP status code seen when querying the domain
 */
@property (nonatomic) NSUInteger statusCode;

/**
 Convience method to get the version of libcurl used by CKServerInfo

 @return A string representing the libcurl version
 */
+ (NSString *) libcurlVersion;

@end
