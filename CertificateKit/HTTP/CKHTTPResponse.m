//
//  CKHTTPResponse.m
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

#import <CertificateKit/CKHTTPResponse.h>

@interface CKHTTPResponse ()

@property (nonatomic, nonnull, readwrite) NSString * host;
@property (nonatomic, readwrite) NSUInteger statusCode;
@property (strong, nonatomic, nonnull, readwrite) CKHTTPHeaders * headers;

@end

@implementation CKHTTPResponse

- (id) initWithHost:(NSString *)host statusCode:(NSUInteger)statusCode headers:(CKHTTPHeaders *)headers {
    self = [super init];
    self.host = host;
    self.statusCode = statusCode;
    self.headers = headers;
    return self;
}

@end
