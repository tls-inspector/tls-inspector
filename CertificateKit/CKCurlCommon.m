//
//  CKCurlCommon.h
//
//  LGPLv3
//
//  Copyright (c) 2020 Ian Spence
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

#import "CKCurlCommon.h"

static id _instance;

@implementation CKCurlCommon

+ (CKCurlCommon *) sharedInstance {
    if (!_instance) {
        _instance = [CKCurlCommon new];
    }
    return _instance;
}

- (CURL *) curlHandle {
    CURL * curl;

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
    if (!curl) {
        return nil;
    }

    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString * version = infoDictionary[@"CFBundleShortVersionString"];
    NSString * userAgent = [NSString stringWithFormat:@"CertificateKit TLS-Inspector/%@ +https://tlsinspector.com/", version];
    curl_easy_setopt(curl, CURLOPT_USERAGENT, userAgent.UTF8String);
    curl_easy_setopt(curl, CURLOPT_FORBID_REUSE, 1L);

    return curl;
}

@end
