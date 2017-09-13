#import <Foundation/Foundation.h>

@interface CKServerInfo : NSObject

@property (strong, nonatomic) NSDictionary<NSString *, NSString *> * headers;
@property (strong, nonatomic) NSDictionary<NSString *, id> * securityHeaders;
@property (nonatomic) NSUInteger statusCode;

@end
