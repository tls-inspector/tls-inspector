#import "DNSResolver.h"

#include <sys/types.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <net/if.h>

@implementation DNSResolver

+ (NSArray<NSString *> *) resolveHostname:(NSString *)hostname error:(NSError **)error {
    struct addrinfo hints, *servinfo, *p;
    int rv;
    
    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    
    if ((rv = getaddrinfo([hostname UTF8String], "https", &hints, &servinfo)) != 0) {
        const char * errorString = gai_strerror(rv);
        * error = [NSError errorWithDomain:@"DNSResolver" code:rv userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:errorString]}];
        return nil;
    }
    
    NSMutableArray<NSString *> * addresses = [NSMutableArray new];
    
    for (p = servinfo; p != NULL; p = p->ai_next) {
        struct sockaddr_in * ipv4 = (struct sockaddr_in *)p->ai_addr;
        char ipAddress[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &(ipv4->sin_addr), ipAddress, INET_ADDRSTRLEN);
        [addresses addObject:[NSString stringWithUTF8String:ipAddress]];
    }

    return addresses;
}

@end
