//
//  CKServerInfoGetter.m
//
//  LGPLv3
//
//  Copyright (c) 2016 Ian Spence
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

#import "CKServerInfoGetter.h"
#import "CKServerInfo.h"
#import "CKCurlCommon.h"
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
    PDebug(@"Getting HTTP server info");
    [self getServerInfoForURL:url finished:^(NSError *error) {
        PDebug(@"Finished getting HTTP server info");
        self.finished = YES;
        if (error) {
            [self.delegate getter:self failedTaskWithError:error];
        } else {
            self.serverInfo = [CKServerInfo new];
            self.serverInfo.headers = self.headers;
            self.serverInfo.statusCode = self.statusCode;
            self.serverInfo.redirectedTo = self.redirectedTo;
            self.successful = YES;
            [self.delegate getter:self finishedTaskWithResult:self.serverInfo];
        }
    }];
}

- (void) getServerInfoForURL:(NSURL *)url finished:(void (^)(NSError * error))finished {
    CURLcode response;
    CURL * curl = [[CKCurlCommon sharedInstance] curlHandle];
    if (!curl) {
        PError(@"Unable to create curl session (this shouldn't happen!)");
        curl_global_cleanup();
        finished([NSError errorWithDomain:@"libcurl" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unable to create curl session."}]);
        return;
    }

    self.headers = [NSMutableDictionary new];
    NSError * error;
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString * version = infoDictionary[@"CFBundleShortVersionString"];
    NSString * userAgent = [NSString stringWithFormat:@"CertificateKit TLS-Inspector/%@ +https://tlsinspector.com/", version];

    PDebug(@"Server Info Request: HTTP GET %@", url.absoluteString);

    const char * urlString = url.absoluteString.UTF8String;
    curl_easy_setopt(curl, CURLOPT_URL, urlString);
    curl_easy_setopt(curl, CURLOPT_USERAGENT, userAgent.UTF8String);
    // Since we're only concerned with getting the HTTP servers
    // info, we don't do any verification
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
    curl_easy_setopt(curl, CURLOPT_CAINFO, "");

    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, server_info_write_callback);
    curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, server_info_header_callback);
    curl_easy_setopt(curl, CURLOPT_HEADERDATA, self.headers);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_MAXREDIRS, 10L); // Only follow up-to 10 redirects
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L); // Give up after 5 seconds
    curl_easy_setopt(curl, CURLOPT_COOKIEFILE, ""); // Start the cookie engile (but don't save cookies)
    // Perform the request, res will get the return code
    response = curl_easy_perform(curl);
    if (response == CURLE_OK) {
        char *urlstr = NULL;
        curl_easy_getinfo(curl, CURLINFO_EFFECTIVE_URL, &urlstr);
        if (urlstr != NULL) {
            NSURL * redirectURL = [NSURL URLWithString:[NSString stringWithCString:urlstr encoding:NSASCIIStringEncoding]];
            if (![url.host isEqualToString:redirectURL.host]) {
                PWarn(@"Server redirected to different host: '%@'", redirectURL.absoluteString);
                self.redirectedTo = redirectURL;
            } else {
                PDebug(@"Server redirected to same host: '%@'", redirectURL.absoluteString);
            }
        }
    } else {
        // Check for errors
        NSString * errString = [[NSString alloc] initWithUTF8String:curl_easy_strerror(response)];
        PError(@"Error getting server info: %@", errString);
        error = [NSError errorWithDomain:@"libcurl" code:-1 userInfo:@{NSLocalizedDescriptionKey: errString}];
    }

    long http_code = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
    self.statusCode = http_code;
    PDebug(@"Server Info HTTP Response: %ld", http_code);

    // always cleanup
    curl_easy_cleanup(curl);
    curl_global_cleanup();
    finished(error);
}

static size_t server_info_header_callback(char *buffer, size_t size, size_t nitems, void *userdata) {
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

size_t server_info_write_callback(void *buffer, size_t size, size_t nmemb, void *userp) {
    // We don't really care about the actual HTTP body, so just convince CURL that we did something with it
    // (we don't)
    return size * nmemb;
}

@end
