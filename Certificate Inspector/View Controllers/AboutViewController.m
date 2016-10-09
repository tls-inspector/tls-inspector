//
//  AboutViewController.m
//  Certificate Inspector
//
//  GPLv3 License
//  Copyright (c) 2016 Ian Spence
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

#import "AboutViewController.h"
#import "RecentDomains.h"
@import StoreKit;

@interface AboutViewController () <SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildLabel;
@property (weak, nonatomic) IBOutlet UISwitch *recentSwitch;
- (IBAction)recentSwitch:(UISwitch *)sender;
@property (strong, nonatomic) UIHelper * helper;
@property (strong, nonatomic) RecentDomains * recentDomainsManager;

@end

@implementation AboutViewController
    
static NSString * PROJECT_GITHUB_URL = @"https://github.com/certificate-helper/Certificate-Inspector/";
static NSString * ITUNES_APP_ID = @"1100539810";
static NSString * PROJECT_TESTFLIGHT_APPLICATION = @"https://ianspence.com/certificate-inspector-beta";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recentDomainsManager = [RecentDomains new];
    [self.recentSwitch setOn:self.recentDomainsManager.saveRecentDomains];
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.versionLabel.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.buildLabel.text = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    self.helper = [UIHelper sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"tell_friends"]) {
        NSString * blurb = format(@"Easily view and inspect X509 certificates on your iOS device. %@", PROJECT_GITHUB_URL);
        UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[blurb]
                                                        applicationActivities:nil];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            activityController.popoverPresentationController.sourceView = [cell viewWithTag:1];
        }
        [self presentViewController:activityController animated:YES completion:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"rate_app"]) {
        
        if ([SKStoreProductViewController class] != nil) {
            SKStoreProductViewController * productViewController = [SKStoreProductViewController new];
            productViewController.delegate = self;
            [productViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: ITUNES_APP_ID} completionBlock:nil];
            [self presentViewController:productViewController animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", ITUNES_APP_ID]]];
        }
    } else if ([cell.reuseIdentifier isEqualToString:@"submit_feedback"]) {
        
        [self.helper
         presentActionSheetInViewController:self
         attachToTarget:[ActionTipTarget targetWithView:[cell viewWithTag:1]]
         title:lang(@"What kind of feedback would you like to submit?")
         subtitle:lang(@"All feedback is appreciated!")
         cancelButtonTitle:lang(@"Cancel")
         items:@[
                 lang(@"Something I Like"),
                 lang(@"Something I Don't Like"),
                 lang(@"Request a Feature"),
                 lang(@"Report a Bug")
                 ]
         dismissed:^(NSInteger selectedIndex) {
             switch (selectedIndex) {
                 case 0:
                     [[UIApplication sharedApplication] openURL:
                      [NSURL URLWithString:nstrcat(PROJECT_GITHUB_URL, @"issues/new?labels=commendation")]];
                     break;
                 case 1:
                     [[UIApplication sharedApplication] openURL:
                      [NSURL URLWithString:nstrcat(PROJECT_GITHUB_URL, @"issues/new?labels=complaint")]];
                     break;
                 case 2:
                     [[UIApplication sharedApplication] openURL:
                      [NSURL URLWithString:nstrcat(PROJECT_GITHUB_URL, @"issues/new?labels=enhancement")]];
                     break;
                 case 3:
                     [[UIApplication sharedApplication] openURL:
                      [NSURL URLWithString:nstrcat(PROJECT_GITHUB_URL, @"issues/new?labels=bug")]];
                     break;
                 default:
                     break;
             }
         }];
    } else if ([cell.reuseIdentifier isEqualToString:@"contribute"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PROJECT_GITHUB_URL]];
    }
}

- (IBAction)recentSwitch:(UISwitch *)sender {
    self.recentDomainsManager.saveRecentDomains = sender.isOn;
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
