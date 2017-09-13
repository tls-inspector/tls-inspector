#import <UIKit/UIKit.h>

@interface GetterTableViewController : UITableViewController

- (void) presentGetter:(UIViewController *)parent ForUrl:(NSURL *)url finished:(void (^)(BOOL success))finished;

@end
