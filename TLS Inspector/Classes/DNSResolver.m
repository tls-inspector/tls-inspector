#import "DNSResolver.h"

#include <sys/types.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <net/if.h>

@implementation DNSResolver

+ (NSArray<NSString *> *) resolveHostname:(NSString *)hostname error:(NSError **)error {
    struct addrinfo* result;
    struct addrinfo* res;
    int rv;

    const char * name = [hostname UTF8String];
    
    rv = getaddrinfo(name, NULL, NULL, &result);
    if (rv != 0) {
        const char * errorString = gai_strerror(rv);
        * error = [NSError errorWithDomain:@"DNSResolver" code:rv userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errorString]}];
        return nil;
    }
    
    NSMutableArray<NSString *> * addresses = [NSMutableArray new];

    for (res = result; res != NULL; res = res->ai_next) {
        // Shodan doesn't have much results for IPv6 hosts, so just sticking with A records for now.
        if (res->ai_family == AF_INET) {
            struct sockaddr_in * ipv4 = (struct sockaddr_in *)res->ai_addr;
            char ipAddress[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &(ipv4->sin_addr), ipAddress, INET_ADDRSTRLEN);
            [addresses addObject:[NSString stringWithUTF8String:ipAddress]];
        }
    }
    
    freeaddrinfo(result);
    return addresses;
}

@end
