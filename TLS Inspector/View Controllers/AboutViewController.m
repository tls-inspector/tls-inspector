#import "AboutViewController.h"
#import "RecentDomains.h"
#import "GTAppLinks.h"
@import CHCertificate;

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *opensslVersionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *recentSwitch;
- (IBAction)recentSwitch:(UISwitch *)sender;
@property (strong, nonatomic) UIHelper * helper;
@property (strong, nonatomic) GTAppLinks * appLinks;

@end

@implementation AboutViewController

static NSString * PROJECT_GITHUB_URL = @"https://github.com/certificate-helper/TLS-Inspector/";
static NSString * PROJECT_URL = @"https://tlsinspector.com/";
static NSString * PROJECT_CONTRIBUTE_URL = @"https://github.com/certificate-helper/TLS-inspector/blob/master/CONTRIBUTE.md";
static NSString * PROJECT_TESTFLIGHT_APPLICATION = @"https://tlsinspector.com/beta.html";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.recentSwitch setOn:[RecentDomains sharedInstance].saveRecentDomains];
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.versionLabel.text = format(@"%@ (%@)", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey]);

    self.opensslVersionLabel.text = [CHCertificate openSSLVersion];
    self.helper = [UIHelper sharedInstance];
    self.appLinks = [GTAppLinks new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"tell_friends"]) {
        NSString * blurb = format(@"Easily view and inspect X509 certificates on your iOS device. %@", PROJECT_URL);
        UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[blurb]
                                                        applicationActivities:nil];
        activityController.popoverPresentationController.sourceView = [cell viewWithTag:1];
        [self presentViewController:activityController animated:YES completion:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"rate_app"]) {
        [self.appLinks showAppInAppStore:GTAppStoreIDTLSInspector inViewController:self dismissed:^{
            //
        }];
    } else if ([cell.reuseIdentifier isEqualToString:@"submit_feedback"]) {

        [self.helper
         presentActionSheetInViewController:self
         attachToTarget:[ActionTipTarget targetWithView:[cell viewWithTag:1]]
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
                      showEmailComposeSheetForApp:APP_NAME_TLS_INSPECTOR
                      email:APP_SUPPORT_EMAIL_TLS_INSPECTOR
                      inViewController:self dismissed:^{
                         //
                     }];
                     break;
                 } default:
                     break;
             }
         }];
    } else if ([cell.reuseIdentifier isEqualToString:@"contribute"]) {
        open_url(PROJECT_CONTRIBUTE_URL);
    } else if ([cell.reuseIdentifier isEqualToString:@"beta"]) {
        open_url(PROJECT_TESTFLIGHT_APPLICATION);
    }
}

- (IBAction)recentSwitch:(UISwitch *)sender {
    [RecentDomains sharedInstance].saveRecentDomains = sender.isOn;
}

@end
