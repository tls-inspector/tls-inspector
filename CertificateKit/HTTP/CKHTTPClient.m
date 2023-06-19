//
//  CKHTTPClient.m
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

#import "CKHTTPClient.h"
#import "CKHTTPHeaders.h"

@implementation CKHTTPClient

+ (NSData *) requestForHost:(NSString *)host {
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString * version = infoDictionary[@"CFBundleShortVersionString"];
    NSString * userAgent = [NSString stringWithFormat:@"CertificateKit TLS-Inspector/%@ +https://tlsinspector.com/", version];
    NSString * request = [NSString stringWithFormat:@"GET / HTTP/1.1\r\nHost: %@\r\nUser-Agent: %@\r\n\r\n", host, userAgent];
    return [request dataUsingEncoding:NSASCIIStringEncoding];
}

+ (CKHTTPResponse *) responseFromBIO:(BIO *)bio {
    char responseGreetingB[12];
    int read = BIO_read(bio, &responseGreetingB, 12);
    if (read < 12) {
        return nil;
    }

    NSData * responseGreeting = [NSData dataWithBytes:responseGreetingB length:read];
    NSData * httpVersion = [responseGreeting subdataWithRange:NSMakeRange(0, 8)];
    if (![httpVersion isEqualToData:[@"HTTP/1.1" dataUsingEncoding:NSUTF8StringEncoding]] && ![httpVersion isEqualToData:[@"http/1.1" dataUsingEncoding:NSUTF8StringEncoding]]) {
        return nil;
    }

    NSData * statusCodeBytes = [responseGreeting subdataWithRange:NSMakeRange(9, 3)];
    int statusCode = atoi(statusCodeBytes.bytes);
    if (statusCode < 100 || statusCode > 599) {
        return nil;
    }

    NSMutableData * headerData = [NSMutableData new];
    char headerBuf[102400]; // 100KiB
    bool hasAllHeaders = NO;
    int headersEndIdx = -1;
    while (!hasAllHeaders) {
        read = BIO_read(bio, headerBuf, 102400);
        if (read <= 0) {
            return nil;
        }

        for (int i = 0; i < read-3;) {
            if (headerBuf[i] == '\r' &&
                headerBuf[i+1] == '\n' &&
                headerBuf[i+2] == '\r' &&
                headerBuf[i+3] == '\n') {
                headersEndIdx = i;
                hasAllHeaders = YES;
                break;
            }
            i++;
        }

        [headerData appendBytes:headerBuf length:read];
    }

    CKHTTPHeaders * headers = [[CKHTTPHeaders alloc] initWithData:[headerData subdataWithRange:NSMakeRange(0, headersEndIdx)]];
    CKHTTPResponse * response = [[CKHTTPResponse alloc] initWithStatusCode:(NSUInteger)statusCode headers:headers];

    return response;
}

@end
