#import "OptionsTableViewController.h"
#import "RecentDomains.h"
#import "IconTableViewCell.h"
#import "ContactSupportTableViewController.h"
@import MessageUI;

@interface OptionsTableViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation OptionsTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Remember Recent Lookups");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:[RecentDomains sharedInstance].saveRecentDomains];
            [toggle addTarget:self action:@selector(recentSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 1) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Show HTTP Headers");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.getHTTPHeaders];
            [toggle addTarget:self action:@selector(httpSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 2) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Show Tips");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.showTips];
            [toggle addTarget:self action:@selector(tipsSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 3) {
            UITableViewCell * toggleCell = [tableView dequeueReusableCellWithIdentifier:@"toggle" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[toggleCell viewWithTag:10];
            label.text = l(@"Theme");
            label.textColor = themeTextColor;
            UISegmentedControl * segment = (UISegmentedControl *)[toggleCell viewWithTag:20];
            [segment setTitle:[lang key:@"Dark"] forSegmentAtIndex:0];
            [segment setTitle:[lang key:@"Light"] forSegmentAtIndex:1];
            if (UserOptions.currentOptions.useLightTheme) {
                [segment setSelectedSegmentIndex:1];
            } else {
                [segment setSelectedSegmentIndex:0];
            }
            [segment addTarget:self action:@selector(themeSwitch:) forControlEvents:UIControlEventValueChanged];
            return toggleCell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Query OCSP Responder");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.queryOCSP];
            [toggle addTarget:self action:@selector(ocspSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 1) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Download & Check CRL");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.checkCRL];
            [toggle addTarget:self action:@selector(crlSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        }
    }  else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Enable Debug Logging");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.verboseLogging];
            [toggle addTarget:self action:@selector(verboseLoggingSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 1) {
            IconTableViewCell * cell = [[IconTableViewCell alloc] initWithIcon:FABug color:uihelper.redColor title:l(@"Submit Logs")];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    return nil;
}

- (void) recentSwitch:(UISwitch *)sender {
    [RecentDomains sharedInstance].saveRecentDomains = sender.isOn;
}

- (void) httpSwitch:(UISwitch *)sender {
    UserOptions.currentOptions.getHTTPHeaders = sender.isOn;
}

- (void) tipsSwitch:(UISwitch *)sender {
    UserOptions.currentOptions.showTips = sender.isOn;
}

- (void) ocspSwitch:(UISwitch *)sender {
    UserOptions.currentOptions.queryOCSP = sender.isOn;
}

- (void) crlSwitch:(UISwitch *)sender {
    UserOptions.currentOptions.checkCRL = sender.isOn;
}

- (void) verboseLoggingSwitch:(UISwitch *)sender {
    UserOptions.currentOptions.verboseLogging = sender.isOn;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [lang key:@"General"];
    } else if (section == 1) {
        return [lang key:@"Certificate Status"];
    } else if (section == 2) {
        return [lang key:@"Logging"];
    }
    
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return [lang key:@"certificate_status_footer"];
    } else if (section == 2) {
        return [lang key:@"verbose_logging_footer"];
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 1) {
        [ContactSupportTableViewController collectFeedbackOnController:self finished:^(NSString *comments) {
            [self sendDebugLogsWithComments:comments];
        }];
    }
}

- (void) themeSwitch:(UISegmentedControl *)sender {
    [uihelper
     presentConfirmInViewController:self
     title:l(@"Change Theme")
     body:l(@"You must restart the app for the change to take affect")
     confirmButtonTitle:l(@"Change")
     cancelButtonTitle:l(@"Cancel")
     confirmActionIsDestructive:NO
     dismissed:^(BOOL confirmed) {
         if (confirmed) {
             UserOptions.currentOptions.useLightTheme = sender.selectedSegmentIndex == 1;
             [appState setAppearance];
             UIAlertController * alert = [UIAlertController alertControllerWithTitle:l(@"Restart TLS Inspector") message:l(@"You must restart TLS Inspector for theme changes to take affect.") preferredStyle:UIAlertControllerStyleAlert];
             [self presentViewController:alert animated:YES completion:nil];
         } else {
             [sender setSelectedSegmentIndex:sender.selectedSegmentIndex == 0 ? 1 : 0];
         }
     }];
}

- (void) sendDebugLogsWithComments:(NSString *)comments {
    MFMailComposeViewController * mailController = [MFMailComposeViewController new];
    mailController.mailComposeDelegate = self;

    if (!mailController) {
        return;
    }

    [mailController setSubject:@"TLS Inspector Debug Logs"];
    [mailController setToRecipients:@[@"'TLS Inspector Project Manager' <hello@tlsinspector.com>"]];
    [mailController setMessageBody:[NSString stringWithFormat:@"<p>%@<br/><br/></p><hr/><p><small>Please do not remove the following attachments:</small></p>", comments] isHTML:YES];

    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * cklogPath = [documentsDirectory stringByAppendingPathComponent:@"CertificateKit.log"];
    [mailController addAttachmentData:[NSData dataWithContentsOfFile:cklogPath] mimeType:@"text/plain" fileName:@"TLS Inspector.log"];
    NSString * exceptionsLogPath = [documentsDirectory stringByAppendingPathComponent:@"exceptions.log"];
    if ([NSFileManager.defaultManager fileExistsAtPath:exceptionsLogPath]) {
        [mailController addAttachmentData:[NSData dataWithContentsOfFile:exceptionsLogPath] mimeType:@"text/plain" fileName:@"Exceptions.log"];
    }

    [self presentViewController:mailController animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
