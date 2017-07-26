#import <Foundation/Foundation.h>

@interface CKServerInfo : NSObject

- (void) getServerInfoForURL:(NSURL *)url finished:(void (^)(NSError * error))finished;

@end
