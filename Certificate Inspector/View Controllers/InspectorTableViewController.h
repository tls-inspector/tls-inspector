#import <UIKit/UIKit.h>
#import "CHCertificate.h"

@interface InspectorTableViewController : UITableViewController <NSURLConnectionDelegate>

- (void) loadCertificate:(CHCertificate *)certificate forDomain:(NSString *)domain;

@end
