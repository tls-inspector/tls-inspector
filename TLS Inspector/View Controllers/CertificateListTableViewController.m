#import "CertificateListTableViewController.h"
#import "InspectorTableViewController.h"
#import "TitleValueTableViewCell.h"
#import "NSString+FontAwesome.h"
#import "IconTableViewCell.h"

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
            self.headerViewLabel.text = l(@"Untrusted Chain");
            self.headerView.backgroundColor = uihelper.redColor;
            self.headerButton.tintColor = [UIColor whiteColor];
            break;
    }

    self.headerViewLabel.textColor = [UIColor whiteColor];
    self.headerButton.hidden = NO;

    self.tableView.estimatedRowHeight = 85.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

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
        case 2: {
            NSUInteger count = currentServerInfo.securityHeaders.allKeys.count;
            if (currentServerInfo.redirectedTo != nil) {
                count ++;
            }
            return count;
        }
    }
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CKCertificate * cert = [currentChain.certificates objectAtIndex:indexPath.row];

        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];

        if (cert.revoked.isRevoked) {
            cell.textLabel.text = [lang key:@"{summary} (Revoked)" args:@[[cert summary]]];
            cell.textLabel.textColor = uihelper.redColor;
        } else if (cert.extendedValidation) {
            NSDictionary * names = [cert names];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@ [%@])", [cert summary], [names objectForKey:@"O"], [names objectForKey:@"C"]];
            cell.textLabel.textColor = uihelper.greenColor;
        } else {
            cell.textLabel.text = [cert summary];
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
        NSUInteger idx = indexPath.row;
        if (currentServerInfo.redirectedTo != nil) {
            if (idx == 0) {
                return [[TitleValueTableViewCell alloc] initWithTitle:l(@"Ingored Redirect To") value:currentServerInfo.redirectedTo.host];
            } else {
                idx --;
            }
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
        case CKCertificateChainTrustStatusUntrusted:
            title = l(@"Untrusted Chain");
            body = l(@"untrusted_chain_description");
            break;
        case CKCertificateChainTrustStatusSelfSigned:
            title = l(@"Untrusted Chain");
            body = l(@"self_signed_chain_description");
            break;
        case CKCertificateChainTrustStatusTrusted:
            title = l(@"Trusted Chain");
            body = l(@"trusted_chain_description");
            break;
        case CKCertificateChainTrustStatusRevoked:
            title = l(@"Untrusted Chain");
            body = l(@"revoked_chain_description");
            break;
        case CKCertificateChainTrustStatusInvalidDate:
            title = l(@"Untrusted Chain");
            body = l(@"invalid_date_chain_description");
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
