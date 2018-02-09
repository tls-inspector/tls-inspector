//
//  CKServerInfoGetter.m
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
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

#import "CKServerInfoGetter.h"
#import "CKServerInfo.h"
#include <curl/curl.h>

@interface CKServerInfoGetter ()

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> * headers;
@property (nonatomic) NSUInteger statusCode;
@property (strong, nonatomic) CKServerInfo * serverInfo;
@property (strong, nonatomic) NSURL * redirectedTo;

@end

@implementation CKServerInfoGetter

@synthesize headers;

- (void) performTaskForURL:(NSURL *)url {
    [self getServerInfoForURL:url finished:^(NSError *error) {
        if (error) {
            [self.delegate getter:self failedTaskWithError:error];
        } else {
            self.serverInfo = [CKServerInfo new];
            self.serverInfo.headers = self.headers;
            self.serverInfo.statusCode = self.statusCode;
            self.serverInfo.redirectedTo = self.redirectedTo;
            [self.delegate getter:self finishedTaskWithResult:self.serverInfo];
            self.finished = YES;
        }
    }];
}

- (void) getServerInfoForURL:(NSURL *)url finished:(void (^)(NSError * error))finished {
    CURL * curl;
    CURLcode response;

    curl_global_init(CURL_GLOBAL_DEFAULT);

    self.headers = [NSMutableDictionary new];

    NSError * error;

    curl = curl_easy_init();
    if (curl) {
#ifdef DEBUG
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
#endif

        NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString * version = infoDictionary[@"CFBundleShortVersionString"];
        NSString * userAgent = [NSString stringWithFormat:@"CertificateKit TLS-Inspector/%@ +https://tlsinspector.com/", version];

        const char * urlString = url.absoluteString.UTF8String;
        curl_easy_setopt(curl, CURLOPT_URL, urlString);
        curl_easy_setopt(curl, CURLOPT_USERAGENT, userAgent.UTF8String);
        // Since we're only concerned with getting the HTTP servers
        // info, we don't do any verification
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);

        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, header_callback);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, self.headers);
        curl_easy_setopt(curl, CURLOPT_MAXREDIRS, 10L); // Only follow up-to 10 redirects
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L); // Give up after 5 seconds
        curl_easy_setopt(curl, CURLOPT_COOKIEFILE, ""); // Start the cookie engile (but don't save cookies)
        // Perform the request, res will get the return code
        response = curl_easy_perform(curl);
        if (response == CURLE_OK) {
            char *urlstr = NULL;
            curl_easy_getinfo(curl, CURLINFO_REDIRECT_URL, &urlstr);
            if (urlstr != NULL) {
                NSURL * redirectURL = [NSURL URLWithString:[NSString stringWithCString:urlstr encoding:NSASCIIStringEncoding]];
                self.redirectedTo = redirectURL;
            }
        } else {
            // Check for errors
            NSString * errString = [[NSString alloc] initWithUTF8String:curl_easy_strerror(response)];
            NSLog(@"Error getting server info: %@", errString);
            error = [NSError errorWithDomain:@"libcurl" code:-1 userInfo:@{NSLocalizedDescriptionKey: errString}];
        }

        long http_code = 0;
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
        self.statusCode = http_code;

        // always cleanup
        curl_easy_cleanup(curl);
    } else {
        error = [NSError errorWithDomain:@"libcurl" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unable to create curl session."}];
    }
    curl_global_cleanup();
    finished(error);
}

static size_t header_callback(char *buffer, size_t size, size_t nitems, void *userdata) {
    unsigned long len = nitems * size;
    if (len > 2) {
        NSData * data = [NSData dataWithBytes:buffer length:len - 2]; // Trim the \r\n from the end of the header
        NSString * headerValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray<NSString *> * components = [headerValue componentsSeparatedByString:@": "];
        if (components.count < 2) {
            return len;
        }

        NSString * key = components[0];
        NSInteger keyLength = key.length + 1; // Chop off the ":"
        if ((NSInteger)headerValue.length - keyLength < 0) {
            return len;
        }
        NSString * value = [headerValue substringWithRange:NSMakeRange(keyLength, headerValue.length - keyLength)];
        [((__bridge NSMutableDictionary<NSString *, NSString *> *)userdata)
         setObject:value
         forKey:key];
    }

    return len;
}

size_t write_callback(void *buffer, size_t size, size_t nmemb, void *userp) {
    // We don't really care about the actual HTTP body, so just convince CURL that we did something with it
    // (we don't)
    return size * nmemb;
}

@end
