//
//  CKHTTPServerInfo.m
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

#import <CertificateKit/CKHTTPServerInfo.h>
#import <CertificateKit/CKHTTPResponse.h>

@interface CKHTTPServerInfo ()

@property (strong, nonatomic, nonnull, readwrite) NSDictionary<NSString *, NSArray<NSString *> *> * headers;
@property (strong, nonatomic, nullable, readwrite) NSURL * redirectedTo;
@property (strong, nonatomic) NSDictionary<NSString *, id> * cachedSecurityHeaders;

@end

@implementation CKHTTPServerInfo

+ (CKHTTPServerInfo *) fromHTTPResponse:(CKHTTPResponse *)response {
    CKHTTPServerInfo * r = [CKHTTPServerInfo new];
    r.headers = response.headers.allHeaders;
    r.statusCode = response.statusCode;
    r.redirectedTo = [CKHTTPServerInfo redirectURLFromResponse:response];
    return r;
}

+ (NSURL *) redirectURLFromResponse:(CKHTTPResponse *)response {
    NSString * locationValue = [response.headers valueForHeader:@"Location"];
    if (locationValue == nil) {
        return nil;
    }

    // Attempt to transform a possibly relative path into an absolute URL
    NSURLComponents * urlParts = [[NSURLComponents alloc] initWithString:locationValue];
    if (urlParts.host == nil) {
        urlParts.host = response.host;
    }
    // Drop invalid hosts
    if (urlParts.host.length > 255) {
        return nil;
    }
    if (urlParts.scheme == nil) {
        urlParts.scheme = @"https";
    }
    if (urlParts.port == nil) {
        urlParts.port = @443;
    }
    if (urlParts.path.length >= 1 && [urlParts.path characterAtIndex:0] != '/') {
        urlParts.path = [NSString stringWithFormat:@"/%@", urlParts.path];
    }

    NSURL * destination = [urlParts URL];
    if (destination == nil) {
        PWarn(@"Unknown or unsupported location value: %@", locationValue);
        return nil;
    }
    return destination;
}

- (NSString *) array:(NSArray<NSString *> *)array ContainsCaseInsensitiveString:(NSString *)needle {
    for (NSString * elm in array) {
        NSString * lowercaseHaystack = [elm lowercaseString];
        NSString * lowercaseNeedle = [needle lowercaseString];
        if ([elm isEqualToString:needle] || [lowercaseHaystack isEqualToString:lowercaseNeedle]) {
            return elm;
        }
    }

    return nil;
}

@end
