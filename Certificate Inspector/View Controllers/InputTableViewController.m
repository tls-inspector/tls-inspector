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
#import "RecentDomains.h"

@interface InputTableViewController() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSString * hostAddress;
}

@property (strong, nonatomic) UITextField *hostField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *inspectButton;
- (IBAction)inspectButton:(UIBarButtonItem *)sender;
@property (strong, nonatomic) UIHelper * helper;
@property (strong, nonatomic) NSArray<NSString *> * recentDomains;
@property (strong, nonatomic) RecentDomains * recentDomainManager;

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
    self.recentDomainManager = [RecentDomains new];
    self.helper = [UIHelper sharedInstance];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.recentDomains = [self.recentDomainManager getRecentDomains];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"InspectCertificate"]) {
        [(CertificateListTableViewController *)[segue destinationViewController] setHost:hostAddress];
    }
}

- (void)hostFieldEdit:(id)sender {
    self.inspectButton.enabled = self.hostField.text.length > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.hostField.text.length > 0) {
        [self saveRecent];
        hostAddress = self.hostField.text;
        [self performSegueWithIdentifier:@"InspectCertificate" sender:nil];
        return YES;
    } else {
        return NO;
    }
}

- (void) trustedFingerprintSecFailure:(NSNotification *)n {
    [self.helper
     presentAlertInViewController:self
     title:lang(@"Unable to fetch trusted fingerprint data")
     body:lang(@"We were unable to verify the integrity of the trusted fingerprint data. A checksum mismatch occured.")
     dismissButtonTitle:lang(@"Proceed with caution.")
     dismissed:nil];
}

- (void) saveRecent {
    if (self.recentDomainManager.saveRecentDomains) {
        self.recentDomains = [self.recentDomainManager prependDomain:self.hostField.text];
        [self.tableView reloadData];
    }
}

- (IBAction) inspectButton:(UIBarButtonItem *)sender {
    [self saveRecent];
    hostAddress = self.hostField.text;
    [self performSegueWithIdentifier:@"InspectCertificate" sender:nil];
}

# pragma mark -
# pragma mark Table View

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            return YES;
        default:
            return NO;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.recentDomains.count > 0 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.recentDomains.count;
        default:
            return 0;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return lang(@"FQDN or IP Address");
        case 1:
            return lang(@"Recent Domains");
        default:
            return nil;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return lang(@"Enter the fully qualified domain name or IP address of the host you wish to inspect.  You can specify a port number here as well.");
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
    
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Input"];
            self.hostField = (UITextField *)[cell viewWithTag:1];
            [self.hostField addTarget:self action:@selector(hostFieldEdit:) forControlEvents:UIControlEventEditingChanged];
            self.hostField.delegate = self;
            break;
        } case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            cell.textLabel.text = [self.recentDomains objectAtIndex:indexPath.row];
            break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.recentDomains = [self.recentDomainManager removeDomainAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
        return;
    }
    
    hostAddress = self.recentDomains[indexPath.row];
    [self performSegueWithIdentifier:@"InspectCertificate" sender:nil];
}
@end
