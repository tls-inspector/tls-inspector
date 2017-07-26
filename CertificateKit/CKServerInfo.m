#import "CKServerInfo.h"
#include <curl/curl.h>

@interface CKServerInfo()

@property (strong, nonatomic) NSMutableArray<NSString *> * headers;
@property (nonatomic) NSUInteger statusCode;

@end

@implementation CKServerInfo

@synthesize headers;

- (void) getServerInfoForURL:(NSURL *)url finished:(void (^)(NSError * error))finished {
    CURL * curl;
    CURLcode response;

    curl_global_init(CURL_GLOBAL_DEFAULT);

    self.headers = [NSMutableArray new];

    NSError * error;

    curl = curl_easy_init();
    if (curl) {
        const char * urlString = url.absoluteString.UTF8String;
        curl_easy_setopt(curl, CURLOPT_URL, urlString);
        // Since we're only concerned with getting the HTTP servers
        // info, we don't do any verification
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);

        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, header_callback);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, self.headers);
        // Perform the request, res will get the return code
        response = curl_easy_perform(curl);
        // Check for errors
        if (response != CURLE_OK) {
            NSLog(@"Error getting server info: %s", curl_easy_strerror(response));
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

static size_t header_callback(char *buffer, size_t size,
                              size_t nitems, void *userdata) {
    unsigned long len = nitems * size;
    if (len > 2) {
        NSData * data = [NSData dataWithBytes:buffer length:len - 2]; // Trim the \r\n from the end of the header
        [((__bridge NSMutableArray<NSString *> *)userdata) addObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        return nitems * size;
    }

    return 0;
}

@end
