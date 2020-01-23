//
//  CKCurlCommon.h
//
//  MIT License
//
//  Copyright (c) 2020 Ian Spence
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
