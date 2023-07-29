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
#import "NSData+ByteAtIndex.h"

@implementation CKHTTPClient

+ (NSData *) requestForHost:(NSString *)host {
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString * version = infoDictionary[@"CFBundleShortVersionString"];
    NSString * userAgent = [NSString stringWithFormat:@"CertificateKit TLS-Inspector/%@ +https://tlsinspector.com/", version];
    NSString * request = [NSString stringWithFormat:@"GET / HTTP/1.1\r\nHost: %@\r\nUser-Agent: %@\r\n\r\n", host, userAgent];
    return [request dataUsingEncoding:NSASCIIStringEncoding];
}

+ (void) connectionReadLoop:(nw_connection_t)connection statusCode:(NSNumber *)statusCode mutableData:(NSMutableData *)headerData completed:(void (^)(CKHTTPResponse *))completed {
    nw_connection_receive(connection, 1, 1024, ^(dispatch_data_t content, nw_content_context_t context, bool is_complete, nw_error_t error) {
        bool hasAllHeaders = NO;
        int headersEndIdx = -1;
        NSData * headerBuf = (NSData*)content;
        if (headerBuf == nil || headerBuf.length == 0) {
            return;
        }

        for (int i = 0; i < headerBuf.length-3;) {
            if ([headerBuf byteAtIndex:i] == '\r' &&
                [headerBuf byteAtIndex:i+1] == '\n' &&
                [headerBuf byteAtIndex:i+2] == '\r' &&
                [headerBuf byteAtIndex:i+3] == '\n') {
                headersEndIdx = i;
                hasAllHeaders = YES;
                break;
            }
            i++;
        }

        if (hasAllHeaders) {
            [headerData appendData:[headerBuf subdataWithRange:NSMakeRange(0, headersEndIdx)]];
            CKHTTPHeaders * headers = [[CKHTTPHeaders alloc] initWithData:[headerData subdataWithRange:NSMakeRange(0, headersEndIdx)]];
            CKHTTPResponse * response = [[CKHTTPResponse alloc] initWithStatusCode:statusCode.unsignedIntegerValue headers:headers];
            completed(response);
            return;
        } else if (headerData.length+headerBuf.length > 102400) {
            PError(@"HTTP header data exceeded maximum size");
            completed(nil);
            return;
        } else {
            [headerData appendData:headerBuf];
            [CKHTTPClient connectionReadLoop:connection statusCode:statusCode mutableData:headerData completed:completed];
        }
    });
}

+ (void) responseFromNetworkConnection:(nw_connection_t)connection completed:(void (^)(CKHTTPResponse *))completed {
    nw_connection_receive(connection, 12, 12, ^(dispatch_data_t content, nw_content_context_t context, bool is_complete, nw_error_t error) {
        NSData * data = (NSData*)content;
        if (data.length < 8) {
            PDebug(@"Unknown HTTP response from server");
            completed(nil);
            return;
        }

        NSData * httpVersion = [data subdataWithRange:NSMakeRange(0, 8)];
        if (![httpVersion isEqualToData:[@"HTTP/1.1" dataUsingEncoding:NSUTF8StringEncoding]] && ![httpVersion isEqualToData:[@"http/1.1" dataUsingEncoding:NSUTF8StringEncoding]]) {
            PDebug(@"Unknown HTTP response from server");
            completed(nil);
            return;
        }

        NSData * statusCodeBytes = [data subdataWithRange:NSMakeRange(9, 3)];
        int statusCode = atoi(statusCodeBytes.bytes);
        if (statusCode < 100 || statusCode > 599) {
            PDebug(@"Unknown HTTP response from server");
            completed(nil);
            return;
        }

        NSMutableData * headerData = [NSMutableData new];
        [CKHTTPClient connectionReadLoop:connection statusCode:[NSNumber numberWithInt:statusCode] mutableData:headerData completed:completed];
    });
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
    int totalRead = 0;
    while (!hasAllHeaders) {
        read = BIO_read(bio, headerBuf, 102400);
        if (read <= 0) {
            return nil;
        }
        totalRead += read;
        if (totalRead >= 102400) {
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

+ (CKHTTPResponse *) responseFromStream:(NSInputStream *)stream {
    char responseGreetingB[12];
    NSInteger read = [stream read:(unsigned char *)&responseGreetingB maxLength:12];
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
        read = [stream read:(unsigned char *)&headerBuf maxLength:102400];
        if (read <= 0) {
            return 0;
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
