//
//  InputTableViewController.m
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
