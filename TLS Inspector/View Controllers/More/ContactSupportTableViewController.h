#import <UIKit/UIKit.h>

@interface ContactSupportTableViewController : UITableViewController

+ (void) collectFeedbackOnController:(UIViewController *)controller finished:(void (^)(NSString * comments))finished;

@end
