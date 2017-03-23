#import <Foundation/Foundation.h>

@interface NSDate (ASN1_TIME)

+ (NSDate *) fromASN1_TIME:(const void *)asn;

@end
