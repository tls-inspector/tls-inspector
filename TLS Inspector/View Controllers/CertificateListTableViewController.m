#import "CertificateListTableViewController.h"
#import "TitleValueTableViewCell.h"
#import "NSString+FontAwesome.h"
#import "IconTableViewCell.h"
#import "DNSResolver.h"
#import "ChainExplainTableViewController.h"
#import "HTTPHeadersTableViewController.h"
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
            self.headerViewLabel.textColor = [UIColor whiteColor];
            self.headerButton.tintColor = [UIColor whiteColor];
            break;
        case CKCertificateChainTrustStatusLocallyTrusted:
            self.headerViewLabel.text = l(@"Locally Trusted Chain");
            self.headerView.backgroundColor = uihelper.altGreenColor;
            self.headerViewLabel.textColor = [UIColor whiteColor];
            self.headerButton.tintColor = [UIColor whiteColor];
            break;
        case CKCertificateChainTrustStatusUntrusted:
        case CKCertificateChainTrustStatusRevokedLeaf:
        case CKCertificateChainTrustStatusRevokedIntermediate:
        case CKCertificateChainTrustStatusSelfSigned:
        case CKCertificateChainTrustStatusInvalidDate:
        case CKCertificateChainTrustStatusWrongHost:
        case CKCertificateChainTrustStatusSHA1Leaf:
        case CKCertificateChainTrustStatusSHA1Intermediate:
            self.headerViewLabel.text = l(@"Untrusted Chain");
            self.headerView.backgroundColor = uihelper.redColor;
            self.headerViewLabel.textColor = [UIColor whiteColor];
            self.headerButton.tintColor = [UIColor whiteColor];
            break;
    }

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
    if (UserOptions.currentOptions.getHTTPHeaders) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return currentChain.certificates.count;
        case 1:
            if (currentServerInfo.redirectedTo != nil) {
                return 4;
            }
            return 3;
        case 2: {
            NSUInteger count = currentServerInfo.securityHeaders.allKeys.count;
            return count + 1;
        }
    }
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CKCertificate * cert = [currentChain.certificates objectAtIndex:indexPath.row];

        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];

        NSString * summary = cert.summary;
        if (cert.revoked.isRevoked) {
            cell.textLabel.text = [lang key:@"{commonName} (Revoked)" args:@[summary]];
            cell.textLabel.textColor = uihelper.redColor;
        } else if (cert.isExpired) {
            cell.textLabel.text = [lang key:@"{commonName} (Expired)" args:@[summary]];
            cell.textLabel.textColor = uihelper.redColor;
        } else if (cert.isNotYetValid) {
            cell.textLabel.text = [lang key:@"{commonName} (Not Yet Valid)" args:@[summary]];
            cell.textLabel.textColor = uihelper.redColor;
        } else if ([cert.signatureAlgorithm hasPrefix:@"sha1"] && !cert.isRootCA) {
            cell.textLabel.text = [lang key:@"{commonName} (Insecure)" args:@[summary]];
            cell.textLabel.textColor = uihelper.redColor;
        } else if (cert.extendedValidation) {
            CKNameObject * name = cert.subject;
            cell.textLabel.text = [lang key:@"{commonName} ({orgName} {countryName})" args:@[name.commonName, name.organizationName, name.countryName]];
            cell.textLabel.textColor = uihelper.greenColor;
        } else {
            if (!ATLEAST_IOS_13) {
                cell.textLabel.textColor = themeTextColor;
            }
            cell.textLabel.text = summary;
        }

        return cell;
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                return [[TitleValueTableViewCell alloc] initWithTitle:l(@"Negotiated Cipher Suite") value:currentChain.cipherSuite];
            case 1:
                return [[TitleValueTableViewCell alloc] initWithTitle:l(@"Negotiated Version") value:currentChain.protocol];
            case 2:
                return [[TitleValueTableViewCell alloc] initWithTitle:l(@"Remote Address") value:currentChain.remoteAddress];
            case 3:
                return [[TitleValueTableViewCell alloc] initWithTitle:l(@"Server Redirected To") value:currentServerInfo.redirectedTo.host];
        }
    } else if (indexPath.section == 2) {
        NSUInteger idx = indexPath.row;
        if (idx >= currentServerInfo.securityHeaders.allKeys.count) {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            cell.textLabel.text = [lang key:@"View All"];
            if (!ATLEAST_IOS_13) {
                cell.textLabel.textColor = themeTextColor;
            }
            return cell;
        }

        NSString * key = [currentServerInfo.securityHeaders.allKeys objectAtIndex:idx];
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
    } else if (indexPath.section == 2 && indexPath.row >= currentServerInfo.securityHeaders.allKeys.count) {
        [self performSegueWithIdentifier:@"Headers" sender:nil];
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
    [self performSegueWithIdentifier:@"Explain" sender:nil];
}

- (IBAction) closeButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        [appState.getterViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Explain"]) {
        [(ChainExplainTableViewController *)segue.destinationViewController explainTrustStatus:currentChain.trusted];
    } else if ([segue.identifier isEqualToString:@"Headers"]) {
        [(HTTPHeadersTableViewController *)segue.destinationViewController setHeaders:currentServerInfo.headers];
    }
}

@end
