#import "CKServerInfoGetter.h"
#import "CKServerInfo.h"
#include <curl/curl.h>

@interface CKServerInfoGetter ()

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> * headers;
@property (nonatomic) NSUInteger statusCode;
@property (strong, nonatomic) CKServerInfo * serverInfo;

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
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);
        // Perform the request, res will get the return code
        response = curl_easy_perform(curl);
        // Check for errors
        if (response != CURLE_OK) {
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
