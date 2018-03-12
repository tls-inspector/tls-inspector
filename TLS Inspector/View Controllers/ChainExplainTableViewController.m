#import "ChainExplainTableViewController.h"
#import "TitleValueTableViewCell.h"
#import "NSString+FontAwesome.h"

@interface ChainExplainTableViewController ()

@property (strong, nonatomic) NSString * labelIcon;
@property (strong, nonatomic) UIColor * labelIconColor;
@property (strong, nonatomic) NSString * labelText;
@property (strong, nonatomic) NSString * explanationString;
@property (strong, nonatomic) NSString * secureString;

@end

@implementation ChainExplainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) explainTrustStatus:(CKCertificateChainTrustStatus)status {
    switch (status) {
        case CKCertificateChainTrustStatusTrusted:
            self.labelText = l(@"Trusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FACheckCircle];
            self.labelIconColor = uihelper.greenColor;
            self.explanationString = l(@"explanation::trust");
            self.secureString = l(@"secure::trust");
            break;
        case CKCertificateChainTrustStatusLocallyTrusted:
            self.labelText = l(@"Locally Trusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FACheckCircle];
            self.labelIconColor = uihelper.altGreenColor;
            self.explanationString = l(@"explanation::local_trust");
            self.secureString = l(@"secure::local_trust");
            break;
        case CKCertificateChainTrustStatusUntrusted:
            self.labelText = l(@"Untrusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
            self.labelIconColor = uihelper.redColor;
            self.explanationString = l(@"explanation::untrusted");
            self.secureString = l(@"secure::untrusted");
            break;
        case CKCertificateChainTrustStatusSelfSigned:
            self.labelText = l(@"Untrusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
            self.labelIconColor = uihelper.redColor;
            self.explanationString = l(@"explanation::self_signed");
            self.secureString = l(@"secure::self_signed");
            break;
        case CKCertificateChainTrustStatusRevokedLeaf:
            self.labelText = l(@"Untrusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
            self.labelIconColor = uihelper.redColor;
            self.explanationString = l(@"explanation::revoked");
            self.secureString = l(@"secure::revoked");
            break;
        case CKCertificateChainTrustStatusRevokedIntermediate:
            self.labelText = l(@"Untrusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
            self.labelIconColor = uihelper.redColor;
            self.explanationString = l(@"explanation::revoked");
            self.secureString = l(@"secure::revoked");
            break;
        case CKCertificateChainTrustStatusInvalidDate:
            self.labelText = l(@"Untrusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
            self.labelIconColor = uihelper.redColor;
            self.explanationString = l(@"explanation::invalid_date");
            self.secureString = l(@"secure::invalid_date");
            break;
        case CKCertificateChainTrustStatusSHA1Intermediate:
            self.labelText = l(@"Untrusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
            self.labelIconColor = uihelper.redColor;
            self.explanationString = l(@"explanation::sha1_int");
            self.secureString = l(@"secure::sha1_int");
            break;
        case CKCertificateChainTrustStatusSHA1Leaf:
            self.labelText = l(@"Untrusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
            self.labelIconColor = uihelper.redColor;
            self.explanationString = l(@"explanation::sha1_leaf");
            self.secureString = l(@"secure::sha1_leaf");
            break;
        case CKCertificateChainTrustStatusWrongHost:
            self.labelText = l(@"Untrusted Chain");
            self.labelIcon = [NSString fontAwesomeIconStringForEnum:FAExclamationCircle];
            self.labelIconColor = uihelper.redColor;
            self.explanationString = l(@"explanation::wrong_host");
            self.secureString = l(@"secure::wrong_host");
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Icon" forIndexPath:indexPath];
        UILabel * titleLabel = [cell viewWithTag:1];
        UILabel * iconLabel = [cell viewWithTag:2];

        iconLabel.text = self.labelIcon;
        iconLabel.textColor = self.labelIconColor;
        titleLabel.text = self.labelText;
        titleLabel.textColor = themeTextColor;
        
        return cell;
    } else if (indexPath.section == 1) {
        return [[TitleValueTableViewCell alloc] initWithTitle:l(@"What does this mean?") value:self.explanationString];
    } else if (indexPath.section == 2) {
        return [[TitleValueTableViewCell alloc] initWithTitle:l(@"Is the connection to this site secure?") value:self.secureString];
    }
    
    return nil;
}

@end
