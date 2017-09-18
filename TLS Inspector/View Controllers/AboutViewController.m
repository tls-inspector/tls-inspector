#import "AboutViewController.h"
#import "RecentDomains.h"
#import "GTAppLinks.h"
#import "TitleValueTableViewCell.h"

@interface AboutViewController ()

@property (strong, nonatomic) GTAppLinks * appLinks;

@end

@implementation AboutViewController

static NSString * PROJECT_GITHUB_URL = @"https://github.com/certificate-helper/TLS-Inspector/";
static NSString * PROJECT_URL = @"https://tlsinspector.com/";
static NSString * PROJECT_CONTRIBUTE_URL = @"https://github.com/certificate-helper/TLS-inspector/blob/master/CONTRIBUTE.md";
static NSString * PROJECT_TESTFLIGHT_APPLICATION = @"https://tlsinspector.com/beta.html";

- (void) viewDidLoad {
    [super viewDidLoad];
    self.appLinks = [GTAppLinks new];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

# pragma mark - Table View Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 3;
        case 2:
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
            label.text = l(@"Show Tips");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:![AppDefaults boolForKey:HIDE_TIPS]];
            [toggle addTarget:self action:@selector(tipsSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 2) {
            UITableViewCell * toggleCell = [tableView dequeueReusableCellWithIdentifier:@"toggle" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[toggleCell viewWithTag:10];
            label.text = l(@"Theme");
            label.textColor = themeTextColor;
            UISegmentedControl * segment = (UISegmentedControl *)[toggleCell viewWithTag:20];
            [segment setTitle:[lang key:@"Dark"] forSegmentAtIndex:0];
            [segment setTitle:[lang key:@"Light"] forSegmentAtIndex:1];
            if ([AppDefaults boolForKey:USE_LIGHT_THEME]) {
                [segment setSelectedSegmentIndex:1];
            } else {
                [segment setSelectedSegmentIndex:0];
            }
            [segment addTarget:self action:@selector(themeSwitch:) forControlEvents:UIControlEventValueChanged];
            return toggleCell;
        }
    } else if (indexPath.section == 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"action" forIndexPath:indexPath];
        UILabel * label = (UILabel *)[cell viewWithTag:1];
        label.textColor = themeTextColor;
        switch (indexPath.row) {
            case 0:
                label.text = l(@"Tell Friends About TLS Inspector");
                break;
            case 1:
                label.text = l(@"Rate TLS Inspector in the App Store");
                break;
            case 2:
                label.text = l(@"Submit Feedback");
                break;
        }
        return cell;
    } else if (indexPath.section == 2) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"action" forIndexPath:indexPath];
        UILabel * label = (UILabel *)[cell viewWithTag:1];
        label.textColor = themeTextColor;
        switch (indexPath.row) {
            case 0:
                label.text = l(@"Contribute on GitHub");
                break;
            case 1:
                label.text = l(@"Test New Features");
                break;
        }
        return cell;
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        NSString * blurb = format(@"Trust & Safety On-the-go with TLS Inspector: %@", PROJECT_URL);
        UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[blurb]
                                                        applicationActivities:nil];
        activityController.popoverPresentationController.sourceView = [tableView cellForRowAtIndexPath:indexPath];
        [self presentViewController:activityController animated:YES completion:nil];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [self.appLinks showAppInAppStore:1100539810 inViewController:self dismissed:^{
            //
        }];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        [uihelper
         presentActionSheetInViewController:self
         attachToTarget:[ActionTipTarget targetWithView:[tableView cellForRowAtIndexPath:indexPath]]
         title:l(@"What kind of feedback would you like to submit?")
         subtitle:l(@"All feedback is appreciated!")
         cancelButtonTitle:l(@"Cancel")
         items:@[
                 l(@"Report Issue on GitHub"),
                 l(@"Contact Us")
                 ]
         dismissed:^(NSInteger selectedIndex) {
             switch (selectedIndex) {
                 case 0:
                     open_url(nstrcat(PROJECT_GITHUB_URL, @"issues/new"));
                     break;
                 case 1: {
                     [self.appLinks
                      showEmailComposeSheetForApp:@"TLS Inspector"
                      email:@"'TLS Inspector Project Manager' <tls-inspector@ecnepsnai.com>"
                      inViewController:self dismissed:^{
                         //
                     }];
                     break;
                 } default:
                     break;
             }
         }];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        open_url(PROJECT_CONTRIBUTE_URL);
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        open_url(PROJECT_TESTFLIGHT_APPLICATION);
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return l(@"Options");
        case 1:
            return l(@"Share & Feedback");
        case 2:
            return l(@"Get Involved");
    }
    return @"";
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 1: {
            NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
            return format(@"%@ (%@). %@, %@",
                          [infoDictionary objectForKey:@"CFBundleShortVersionString"],
                          [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey],
                          [CKCertificate openSSLVersion],
                          [CKServerInfo libcurlVersion]);
        } case 2:
            return l(@"TLS Inspector is Free and Libre software licensed under GNU GPLv3. TLS Inspector is copyright © 2016 Ian Spence.");
    }
    return @"";
}

- (void) recentSwitch:(UISwitch *)sender {
    [RecentDomains sharedInstance].saveRecentDomains = sender.isOn;
}

- (void) tipsSwitch:(UISwitch *)sender {
    [AppDefaults setBool:!sender.isOn forKey:HIDE_TIPS];
}

- (void) themeSwitch:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [AppDefaults setBool:NO forKey:USE_LIGHT_THEME];
    } else {
        [AppDefaults setBool:YES forKey:USE_LIGHT_THEME];
    }
}

@end
