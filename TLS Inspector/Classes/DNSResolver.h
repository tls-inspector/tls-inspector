#import <Foundation/Foundation.h>

@interface DNSResolver : NSObject

+ (NSArray<NSString *> * _Nullable) resolveHostname:(NSString * _Nonnull)hostname error:(NSError * _Nullable * _Nullable)error;

@end
