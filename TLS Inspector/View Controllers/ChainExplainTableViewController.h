#import <UIKit/UIKit.h>
@import CertificateKit;

@interface ChainExplainTableViewController : UITableViewController

- (void) explainTrustStatus:(CKCertificateChainTrustStatus)status;

@end
