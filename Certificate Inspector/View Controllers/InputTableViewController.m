//
//  InputTableViewController.m
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

#import "InputTableViewController.h"
#import "CertificateListTableViewController.h"
#import "TrustedFingerprints.h"
#import "UIHelper.h"

@interface InputTableViewController()

@property (weak, nonatomic) IBOutlet UITextField *hostField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *inspectButton;
- (IBAction)hostFieldEdit:(id)sender;
@property (strong, nonatomic) UIHelper * helper;

@end

@implementation InputTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TrustedFingerprints sharedInstance];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(trustedFingerprintSecFailure:)
     name:kTrustedFingerprintRemoteSecFailure
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(trustedFingerprintSecFailure:)
     name:kTrustedFingerprintLocalSecFailure
     object:nil];
    self.helper = [UIHelper sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"InspectCertificate"]) {
        [(CertificateListTableViewController *)[segue destinationViewController] setHost:self.hostField.text];
    }
}

- (IBAction)hostFieldEdit:(id)sender {
    self.inspectButton.enabled = self.hostField.text.length > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self performSegueWithIdentifier:@"InspectCertificate" sender:nil];
    return YES;
}

- (void) trustedFingerprintSecFailure:(NSNotification *)n {
    [self.helper
     presentAlertInViewController:self
     title:lang(@"Unable to fetch trusted fingerprint data")
     body:lang(@"We were unable to verify the integrity of the trusted fingerprint data. A checksum mismatch occured.")
     dismissButtonTitle:lang(@"Proceed with caution.")
     dismissed:nil];
}

@end
