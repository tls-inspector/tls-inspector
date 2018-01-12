#import <Foundation/Foundation.h>

@interface CKGetterTask : NSObject

- (void) performTaskForURL:(NSURL *)url;
@property (strong, nonatomic) id delegate;
@property (nonatomic) NSUInteger tag;
@property (nonatomic) BOOL finished;

@end

@protocol CKGetterTaskDelegate

@required

- (void) getter:(CKGetterTask *)getter finishedTaskWithResult:(id)data;
- (void) getter:(CKGetterTask *)getter failedTaskWithError:(NSError *)error;

@end
