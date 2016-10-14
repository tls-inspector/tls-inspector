//
//  ValueViewController.m
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

#import "ValueViewController.h"
#import "UIHelper.h"

@interface ValueViewController () {
    UIHelper * uihelper;
}

@property (strong, nonatomic) NSString * value;
@property (strong, nonatomic) NSString * viewTitle;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ValueViewController

- (void)viewDidLoad {
    self.textView.text = self.value;
    self.title = self.viewTitle;
    uihelper = [UIHelper sharedInstance];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                              target:self action:@selector(actionButton:)];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadValue:(NSString *)value title:(NSString *)title {
    _value = value;
    _viewTitle = title;
}

- (void)actionButton:(id)sender {
    [uihelper presentActionSheetInViewController:self
                                  attachToTarget:[ActionTipTarget targetWithBarButtonItem:self.navigationItem.rightBarButtonItem]
                                           title:self.title
                                        subtitle:langv(@"%lu characters", self.value.length)
                               cancelButtonTitle:lang(@"Cancel")
                                           items:@[lang(@"Copy"), lang(@"Verify"), lang(@"Share")]
                                       dismissed:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0: { // Copy
                [[UIPasteboard generalPasteboard] setString:self.value];
                break;
            } case 1: { // Verify
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:lang(@"Verify Value")
                                                                                         message:lang(@"Enter the value to verify")
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = lang(@"Value");
                }];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:lang(@"Cancel")
                                                                       style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:lang(@"Verify")
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
                                                                     UITextField * inputField = alertController.textFields.firstObject;
                                                                     [self verifyValue:inputField.text];
                                                                 }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
                break;
            } case 2: { // Share
                UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                                initWithActivityItems:@[self.value]
                                                                applicationActivities:nil];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    activityController.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
                }
                [self presentViewController:activityController animated:YES completion:nil];
                break;
            }
        }
    }];
}

- (void) verifyValue:(NSString *)value {
    NSString * (^formatValue)(NSString *) = ^NSString *(NSString * unformattedValue) {
        return [[unformattedValue lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    };
    NSString * formattedCurrentValue = formatValue(self.value);
    NSString * formattedExpectedValue = formatValue(value);
    if ([formattedExpectedValue isEqualToString:formattedCurrentValue]) {
        [uihelper presentAlertInViewController:self title:lang(@"Verified") body:lang(@"Both values matched.") dismissButtonTitle:lang(@"Dismiss") dismissed:nil];
    } else {
        [uihelper presentAlertInViewController:self title:lang(@"Not Verified") body:lang(@"Values do not match.") dismissButtonTitle:lang(@"Dismiss") dismissed:nil];
    }
}
@end
