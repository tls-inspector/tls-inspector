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

    if (Console.level == CKLoggingLevelDebug) {
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, libcurl_write_callback);
    } else {
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 0L);
    }

    return curl;
}

size_t libcurl_write_callback(char *ptr, size_t size, size_t nmemb, void *userdata) {
    NSString * string = [[NSString alloc] initWithUTF8String:ptr];
    [Console writeDebug:string];
    return size * nmemb;
}

@end
