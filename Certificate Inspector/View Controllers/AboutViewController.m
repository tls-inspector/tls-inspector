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

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) UIHelper * helper;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
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
        activityController.popoverPresentationController.sourceView = [cell viewWithTag:1];
        [self presentViewController:activityController animated:YES completion:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"submit_feedback"]) {
        [self.helper
         presentActionSheetInViewController:self
         attachToView:[cell viewWithTag:1]
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

@end
