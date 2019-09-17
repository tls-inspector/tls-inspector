#import "OptionsTableViewController.h"
#import "RecentDomains.h"
#import "IconTableViewCell.h"
#import "ContactSupportTableViewController.h"
#import "AppLinks.h"

@interface OptionsTableViewController ()

@property (strong, nonatomic) AppLinks * appLinks;

@end

@implementation OptionsTableViewController

typedef NS_ENUM(NSInteger, TableSections) {
    SectionGeneral = 0,
    SectionAppearance,
    SectionCertificateStatus,
    SectionFingerprints,
    SectionLogging,
    SectionLast
};

- (void) viewDidLoad {
    self.appLinks = [AppLinks new];
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionLast;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SectionGeneral) {
        return 4;
    } else if (section == SectionAppearance) {
        if (ATLEAST_IOS_13) {
            return 0;
        }
        return 1;
    } else if (section == SectionCertificateStatus) {
        return 2;
    } else if (section == SectionFingerprints) {
        return 4;
    } else if (section == SectionLogging) {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionGeneral) {
        if (indexPath.row == 0) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Remember Recent Lookups");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:[RecentDomains sharedInstance].saveRecentDomains];
            [toggle addTarget:self action:@selector(recentSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 1) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Show HTTP Headers");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.getHTTPHeaders];
            [toggle addTarget:self action:@selector(httpSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 2) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Show Tips");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.showTips];
            [toggle addTarget:self action:@selector(tipsSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 3) {
            IconTableViewCell * cell = [[IconTableViewCell alloc] initWithIcon:FACog color:uihelper.blueColor title:l(@"Advanced Settings")];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    } else if (indexPath.section == SectionAppearance) {
        UITableViewCell * toggleCell = [tableView dequeueReusableCellWithIdentifier:@"toggle" forIndexPath:indexPath];
        UILabel * label = (UILabel *)[toggleCell viewWithTag:10];
        label.text = l(@"Theme");
        if (!ATLEAST_IOS_13) {
            label.textColor = themeTextColor;
        }
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
    } else if (indexPath.section == SectionCertificateStatus) {
        if (indexPath.row == 0) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Query OCSP Responder");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.queryOCSP];
            [toggle addTarget:self action:@selector(ocspSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 1) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Download & Check CRL");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.checkCRL];
            [toggle addTarget:self action:@selector(crlSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        }
    } else if (indexPath.section == SectionFingerprints) {
        if (indexPath.row == 0) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"MD5");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.showFingerprintMD5];
            [toggle addTarget:self action:@selector(md5Switch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 1) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"SHA-128");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.showFingerprintSHA128];
            [toggle addTarget:self action:@selector(sha128Switch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 2) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"SHA-256");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.showFingerprintSHA256];
            [toggle addTarget:self action:@selector(sha256Switch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 3) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"SHA-512");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.showFingerprintSHA512];
            [toggle addTarget:self action:@selector(sha512Switch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        }
    } else if (indexPath.section == SectionLogging) {
        if (indexPath.row == 0) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Enable Debug Logging");
            if (!ATLEAST_IOS_13) {
                label.textColor = themeTextColor;
            }
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

- (void) md5Switch:(UISwitch *)sender {
    UserOptions.currentOptions.showFingerprintMD5 = sender.isOn;
}

- (void) sha128Switch:(UISwitch *)sender {
    UserOptions.currentOptions.showFingerprintSHA128 = sender.isOn;
}

- (void) sha256Switch:(UISwitch *)sender {
    UserOptions.currentOptions.showFingerprintSHA256 = sender.isOn;
}

- (void) sha512Switch:(UISwitch *)sender {
    UserOptions.currentOptions.showFingerprintSHA512 = sender.isOn;
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SectionGeneral) {
        return [lang key:@"General"];
    } else if (section == SectionAppearance) {
        return [lang key:@"Appearance"];
    } else if (section == SectionCertificateStatus) {
        return [lang key:@"Certificate Status"];
    } else if (section == SectionFingerprints) {
        return [lang key:@"Show Certificate Fingerprint"];
    } else if (section == SectionLogging) {
        return [lang key:@"Logging"];
    }
    
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == SectionCertificateStatus) {
        return [lang key:@"certificate_status_footer"];
    } else if (section == SectionLogging) {
        return [lang key:@"verbose_logging_footer"];
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionGeneral && indexPath.row == 3) {
        [self performSegueWithIdentifier:@"CryptoOptionsSegue" sender:nil];
    } else if (indexPath.section == SectionLogging && indexPath.row == 1) {
        if (UserOptions.currentOptions.verboseLogging && UserOptions.currentOptions.inspectionsWithVerboseLogging < 1) {
            [uihelper presentAlertInViewController:self title:[lang key:@"Debug Logging Enabled"] body:[lang key:@"You must inspect at least one site with debug logging enabled before you can submit logs"] dismissButtonTitle:[lang key:@"Dismiss"] dismissed:nil];
        } else {
            [ContactSupportTableViewController collectFeedbackOnController:self finished:^(NSString *comments) {
                [self sendDebugLogsWithComments:comments];
            }];
        }
    }
}

- (void) themeSwitch:(UISegmentedControl *)sender {
    UserOptions.currentOptions.useLightTheme = sender.selectedSegmentIndex == 1;
    [appState setAppearance];
    [NSNotificationCenter.defaultCenter postNotificationName:CHANGE_THEME_NOTIFICATION object:nil];

    // Do this here (and not in app state) since state is shared with the
    // extension, and sharedApplication isn't defined there.
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        for (UIView *view in window.subviews) {
            [view removeFromSuperview];
            [window addSubview:view];
        }
        NSLog(@"Reloaded window");
    }

    [self.tableView reloadData];
}

- (void) sendDebugLogsWithComments:(NSString *)comments {
    [self.appLinks showEmailComposeSheetForAppInViewController:self withComments:comments includeLogs:YES dismissed:nil];
}

@end
