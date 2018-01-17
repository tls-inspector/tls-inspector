#import "CertificateListTableViewController.h"
#import "TitleValueTableViewCell.h"
#import "NSString+FontAwesome.h"
#import "IconTableViewCell.h"
#import "DNSResolver.h"
@import SafariServices;

@interface CertificateListTableViewController ()

@property (weak, nonatomic) IBOutlet UIView * headerView;
@property (weak, nonatomic) IBOutlet UILabel * headerViewLabel;
@property (weak, nonatomic) IBOutlet UIButton * headerButton;

- (IBAction) headerButton:(id)sender;

@end

@implementation CertificateListTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = currentChain.domain;

    switch (currentChain.trusted) {
        case CKCertificateChainTrustStatusTrusted:
            self.headerViewLabel.text = l(@"Trusted Chain");
            self.headerView.backgroundColor = uihelper.greenColor;
            self.headerButton.tintColor = [UIColor whiteColor];
            break;
        case CKCertificateChainTrustStatusUntrusted:
        case CKCertificateChainTrustStatusRevoked:
        case CKCertificateChainTrustStatusSelfSigned:
        case CKCertificateChainTrustStatusInvalidDate:
        case CKCertificateChainTrustStatusWrongHost:
        case CKCertificateChainTrustStatusSHA1Leaf:
        case CKCertificateChainTrustStatusSHA1Intermediate:
            self.headerViewLabel.text = l(@"Untrusted Chain");
            self.headerView.backgroundColor = uihelper.redColor;
            self.headerButton.tintColor = [UIColor whiteColor];
            break;
    }

    self.headerViewLabel.textColor = [UIColor whiteColor];
    self.headerButton.hidden = NO;

    self.tableView.estimatedRowHeight = 85.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];

    [uihelper applyStylesToNavigationBar:self.navigationController.navigationBar];

#ifdef EXTENSION
    [self.navigationItem
     setLeftBarButtonItem:[[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                           target:self
                           action:@selector(dismissView:)]];
#endif
    if (isRegular) {
        [self.tableView
         selectRowAtIndexPath:[NSIndexPath
                               indexPathForRow:0
                               inSection:0]
         animated:NO
         scrollPosition:UITableViewScrollPositionTop];
    }
}

#ifdef EXTENSION
- (void) dismissView:(id)sender {
    [appState.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}
#endif

- (void) showActionSheet:(id)sender {
    [uihelper
     presentActionSheetInViewController:self
     attachToTarget:[ActionTipTarget targetWithBarButtonItem:sender]
     title:currentChain.domain
     subtitle:nil
     cancelButtonTitle:[lang key:@"Cancel"]
     items:@[
             l(@"View on SSL Labs"),
             l(@"Search on Shodan"),
             l(@"Search on crt.sh"),
             ]
     dismissed:^(NSInteger itemIndex) {
         if (itemIndex == 0) {
             NSString * domain = currentChain.domain;
             // If the URL is lacking a protocol the host will be nil
             if (![domain hasPrefix:@"https://"]) {
                 domain = nstrcat(@"https://", domain);
             }

             NSURL * url = [NSURL URLWithString:domain];
             [self openURL:nstrcat(@"https://www.ssllabs.com/ssltest/analyze.html?d=", url.host)];
         } else if (itemIndex == 1) {
             NSError * dnsError;
             NSArray<NSString *> * addresses = [DNSResolver resolveHostname:currentChain.domain error:&dnsError];
             if (addresses && addresses.count >= 1) {
                 [self openURL:nstrcat(@"https://www.shodan.io/host/", addresses[0])];
             } else if (dnsError) {
                 [uihelper presentErrorInViewController:self error:dnsError dismissed:nil];
             }
         } else if (itemIndex == 2) {
             NSString * domain = currentChain.domain;
             // If the URL is lacking a protocol the host will be nil
             if (![domain hasPrefix:@"https://"]) {
                 domain = nstrcat(@"https://", domain);
             }

             NSURL * url = [NSURL URLWithString:domain];
             [self openURL:nstrcat(@"https://crt.sh/?q=", url.host)];
         }
     }];
}

- (void) openURL:(NSString *)url {
    SFSafariViewController * safariViewController = [[SFSafariViewController alloc]
                                                     initWithURL:[NSURL URLWithString:url]];
    [self presentViewController:safariViewController animated:YES completion:nil];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return currentChain.certificates.count > 0 ? l(@"Certificate Chain") : @"";
        case 1:
            return l(@"Connection Information");
        case 2:
            return l(@"Security HTTP Headers");
    }

    return nil;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return currentChain.certificates.count;
        case 1:
            return 2;
        case 2:
            return currentServerInfo.securityHeaders.allKeys.count;
    }
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CKCertificate * cert = [currentChain.certificates objectAtIndex:indexPath.row];

        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];

        if (cert.extendedValidation) {
            CKNameObject * name = cert.subject;
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@ [%@])", name.commonName, name.organizationName, name.countryName];
            cell.textLabel.textColor = uihelper.greenColor;
        } else {
            cell.textLabel.text = cert.summary;
            cell.textLabel.textColor = themeTextColor;
        }

        return cell;
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                return [[TitleValueTableViewCell alloc] initWithTitle:l(@"Negotiated Cipher Suite") value:currentChain.cipherString];
            case 1:
                return [[TitleValueTableViewCell alloc] initWithTitle:l(@"Negotiated Version") value:currentChain.protocolString];
        }
    } else if (indexPath.section == 2) {
        NSString * key = [currentServerInfo.securityHeaders.allKeys objectAtIndex:indexPath.row];
        id value = [currentServerInfo.securityHeaders objectForKey:key];

        FAIcon icon = FAQuestionCircle;
        UIColor * color = [UIColor darkGrayColor];
        if ([value isKindOfClass:[NSNumber class]] && [value isEqualToNumber:@NO]) {
            icon = FATimesCircle;
            color = uihelper.redColor;
        } else if ([value isKindOfClass:[NSString class]]) {
            icon = FACheckCircle;
            color = uihelper.greenColor;
        }

        return [[IconTableViewCell alloc] initWithIcon:icon color:color title:key];
    }

    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        selectedCertificate = [currentChain.certificates objectAtIndex:indexPath.row];
        if (isRegular) {
            notify(RELOAD_CERT_NOTIFICATION);
        } else {
            UIViewController * inspectController = [self.storyboard instantiateViewControllerWithIdentifier:@"Inspector"];
            [self.navigationController pushViewController:inspectController animated:YES];
        }
    }
}

- (BOOL) tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (void) tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        TitleValueTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.valueLabel.text];
    }
}

- (IBAction) headerButton:(id)sender {
    NSString * title, * body;

    switch (currentChain.trusted) {
        case CKCertificateChainTrustStatusTrusted:
            title = l(@"Trusted Chain");
            body = l(@"trusted_chain_description");
            break;
        case CKCertificateChainTrustStatusUntrusted:
            title = l(@"Untrusted Chain");
            body = l(@"chainErr::untrusted");
            break;
        case CKCertificateChainTrustStatusSelfSigned:
            title = l(@"Untrusted Chain");
            body = l(@"chainErr::self_signed");
            break;
        case CKCertificateChainTrustStatusRevoked:
            title = l(@"Untrusted Chain");
            body = l(@"chainErr::revoked");
            break;
        case CKCertificateChainTrustStatusInvalidDate:
            title = l(@"Untrusted Chain");
            body = l(@"chainErr::invalid_date");
            break;
        case CKCertificateChainTrustStatusSHA1Intermediate:
            title = l(@"Untrusted Chain");
            body = l(@"chainErr::sha1_int");
            break;
        case CKCertificateChainTrustStatusSHA1Leaf:
            title = l(@"Untrusted Chain");
            body = l(@"chainErr::sha1_leaf");
            break;
        case CKCertificateChainTrustStatusWrongHost:
            title = l(@"Untrusted Chain");
            body = l(@"chainErr::wrong_host");
            break;
    }

    [uihelper
     presentAlertInViewController:self
     title:title
     body:body
     dismissButtonTitle:l(@"Dismiss")
     dismissed:nil];
}

- (IBAction) closeButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    [appState.getterViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
