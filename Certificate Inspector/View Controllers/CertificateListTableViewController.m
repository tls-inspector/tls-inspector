//
//  CertificateListTableViewController.m
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

#import "CertificateListTableViewController.h"
#import "CHCertificate.h"
#import "InspectorTableViewController.h"
#import "UIHelper.h"

@interface CertificateListTableViewController () {
    UIHelper * uihelper;
    CHCertificate * selectedCertificate;
    BOOL isTrusted;
}

@property (strong, nonatomic) NSArray<CHCertificate *> * certificates;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerViewLabel;
@property (weak, nonatomic) IBOutlet UIButton *headerButton;

- (IBAction)headerButton:(id)sender;

@end

@implementation CertificateListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.certificates = [NSArray<CHCertificate *> new];
    uihelper = [UIHelper sharedInstance];
    self.headerViewLabel.text = lang(@"Loading...");
    if (![self.host hasPrefix:@"http"]) {
        self.host = [NSString stringWithFormat:@"https://%@", self.host];
    }
    [[CHCertificate alloc] fromURL:self.host finished:^(NSError *error, NSArray<CHCertificate *> *certificates, BOOL trustedChain) {
        if (error) {
            [uihelper
             presentAlertInViewController:self
             title:lang(@"Could not get certificates")
             body:error.localizedDescription
             dismissButtonTitle:lang(@"Dismiss")
             dismissed:^(NSInteger buttonIndex) {
                 [self.navigationController popViewControllerAnimated:YES];
             }];
        } else {
            self.certificates = certificates;
            isTrusted = trustedChain;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (trustedChain) {
                    self.headerViewLabel.text = lang(@"Trusted Chain");
                    self.headerView.backgroundColor = [UIColor colorWithRed:0.298 green:0.686 blue:0.314 alpha:1];
                } else {
                    self.headerViewLabel.text = lang(@"Untrusted Chain");
                    self.headerView.backgroundColor = [UIColor colorWithRed:0.957 green:0.263 blue:0.212 alpha:1];
                }
                self.headerViewLabel.textColor = [UIColor whiteColor];
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ViewCert"]) {
        [(InspectorTableViewController *)[segue destinationViewController] loadCertificate:selectedCertificate];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.certificates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHCertificate * cert = [self.certificates objectAtIndex:indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
    cell.textLabel.text = cert.summary;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedCertificate = [self.certificates objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ViewCert" sender:nil];
}

- (IBAction)headerButton:(id)sender {
    NSString * title = isTrusted ? lang(@"Trusted Chain") : lang(@"Untrusted Chain");
    NSString * body = isTrusted ? lang(@"trusted_chain_description") : lang(@"untrusted_chain_description");
    [uihelper
     presentAlertInViewController:self
     title:title
     body:body
     dismissButtonTitle:lang(@"Dismiss")
     dismissed:nil];
}
@end
