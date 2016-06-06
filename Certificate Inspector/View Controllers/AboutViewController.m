//
//  ValueViewController.h
//  Certificate Inspector
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AboutViewController.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) UIHelper * helper;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.helper = [UIHelper withViewController:self];
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
        [self presentViewController:activityController animated:YES completion:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"submit_feedback"]) {
        [self.helper presentActionSheetWithTitle:lang(@"What kind of feedback would you like to submit?")
                                        subtitle:lang(@"All feedback is appreciated!")
                               cancelButtonTitle:lang(@"Cancel")
                                         choices:@[
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
