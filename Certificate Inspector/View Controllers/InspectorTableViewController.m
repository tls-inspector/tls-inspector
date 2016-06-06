//
//  InspectorTableViewController.m
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

#import "InspectorTableViewController.h"
#import "CHCertificate.h"
#import "ValueViewController.h"
#import "TrustedFingerprints.h"
#import "UIHelper.h"

@interface InspectorTableViewController()

@property (strong, nonatomic) CHCertificate  * certificate;
@property (strong, nonatomic) NSMutableArray * cells;
@property (strong, nonatomic) NSMutableArray * certErrors;
@property (strong, nonatomic) NSDictionary   * certVerification;
@property (strong, nonatomic) UIHelper       * helper;

@end

@implementation InspectorTableViewController {
    NSArray<NSDictionary *> * names;
    NSString * MD5Fingerprint;
    NSString * SHA1Fingerprint;
    NSString * SHA256Fingerprint;
    NSString * serialNumber;

    NSString * valueToInspect;
    NSString * titleForValue;
}

typedef NS_ENUM(NSInteger, InspectorSection) {
    CertificateInformation,
    Names,
    Fingerprints,
    CertificateErrorsOrVerification,
    CertificateVerification
};

typedef NS_ENUM(NSInteger, CellTags) {
    CellTagValue = 1,
    CellTagVerified = 2
};

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = self.certificate.summary;
    self.cells = [NSMutableArray new];
    self.certErrors = [NSMutableArray new];
    self.helper = [UIHelper sharedInstance];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.cells addObject:@{@"label": lang(@"Issuer"), @"value": [self.certificate issuer]}];
    [self.cells addObject:@{@"label": lang(@"Algorithm"), @"value": [self.certificate algorithm]}];
    [self.cells addObject:@{@"label": lang(@"Valid To"), @"value": [dateFormatter stringFromDate:[self.certificate notAfter]]}];
    [self.cells addObject:@{@"label": lang(@"Valid From"), @"value": [dateFormatter stringFromDate:[self.certificate notBefore]]}];

    if (![self.certificate validIssueDate]) {
        [self.certErrors addObject:@{@"error": lang(@"Certificate is expired or not valid yet.")}];
    }
    if ([[self.certificate algorithm] hasPrefix:@"sha1"]) {
        [self.certErrors addObject:@{@"error": lang(@"Certificate uses insecure SHA1 algorithm.")}];
    }
    
    NSDictionary * trustResults = [[TrustedFingerprints sharedInstance]
                                   dataForFingerprint:[[self.certificate SHA1Fingerprint]
                                                       stringByReplacingOccurrencesOfString:@" " withString:@""]];
    if (trustResults) {
        if (![[trustResults objectForKey:@"trust"] boolValue]) {
            [self.certErrors addObject:@{@"error": [trustResults objectForKey:@"description"]}];
        } else {
            self.certVerification = trustResults;
        }
    }

    MD5Fingerprint = [self.certificate MD5Fingerprint];
    SHA1Fingerprint = [self.certificate SHA1Fingerprint];
    SHA256Fingerprint = [self.certificate SHA256Fingerprint];
    serialNumber = [self.certificate serialNumber];

    names = [self.certificate names];
}

# pragma mark -
# pragma mark Table View


- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.detailTextLabel.text];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    int base = 3;
    if (self.certErrors.count > 0) {
        base += 1;
    }
    if (self.certVerification) {
        base += 1;
    }
    return base;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case CertificateInformation:
            return self.cells.count;
        case Names:
            return names.count;
        case Fingerprints:
            return 4;
        case CertificateErrorsOrVerification: {
            if (self.certErrors.count > 0) {
                return self.certErrors.count;
            } else if (self.certVerification) {
                return 1;
            }
        }
        case CertificateVerification: {
            return 1;
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case CertificateInformation:
            return lang(@"Certificate Information");
        case Names:
            return lang(@"Subject Names");
        case Fingerprints:
            return lang(@"Fingerprints");
        case CertificateErrorsOrVerification: {
            if (self.certErrors.count > 0) {
                return lang(@"Certificate Errors");
            } else if (self.certVerification) {
                return lang(@"Verified Certificate");
            }
        }
        case CertificateVerification:
            return lang(@"Verified Certificate");
    }
    return @"";
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    if (indexPath.section == CertificateInformation) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetail"];
        NSDictionary * data = [self.cells objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = data[@"value"];
        cell.textLabel.text = data[@"label"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == Names) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetail"];
        NSDictionary * data = [names objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = data[@"name"];
        cell.textLabel.text = lang(data[@"type"]);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == Fingerprints) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetail"];
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"SHA256";
                cell.detailTextLabel.text = SHA256Fingerprint;
                break;
            case 1:
                cell.textLabel.text = @"SHA1";
                cell.detailTextLabel.text = SHA1Fingerprint;
            case 2:
                cell.textLabel.text = @"MD5";
                cell.detailTextLabel.text = MD5Fingerprint;
                break;
            case 3:
                cell.textLabel.text = @"Serial";
                cell.detailTextLabel.text = serialNumber;
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.tag = CellTagValue;
    } else if (indexPath.section == CertificateErrorsOrVerification) {
        if (self.certErrors.count > 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            NSDictionary * data = [self.certErrors objectAtIndex:indexPath.row];
            cell.textLabel.text = data[@"error"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailButton"];
            cell.textLabel.text = self.certVerification[@"description"];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.tag = CellTagVerified;
        }
    } else if (indexPath.section == CertificateVerification) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailButton"];
        cell.textLabel.text = self.certVerification[@"description"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.tag = CellTagVerified;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case CellTagValue: {
            switch (indexPath.row) {
                case 0:
                    valueToInspect = SHA256Fingerprint;
                    titleForValue = @"SHA256 Fingerprint";
                    break;
                case 1:
                    valueToInspect = SHA1Fingerprint;
                    titleForValue = @"SHA1 Fingerprint";
                    break;
                case 2:
                    valueToInspect = MD5Fingerprint;
                    titleForValue = @"MD5 Fingerprint";
                    break;
                case 3:
                    valueToInspect = serialNumber;
                    titleForValue = @"Serial Number";
                    break;
            }
            [self performSegueWithIdentifier:@"ShowValue" sender:nil];
            break;
        } case CellTagVerified: {
            [self showVerifiedAlert];
            break;
        }
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == CellTagVerified) {
        [self showVerifiedAlert];
    }
}

- (void) showVerifiedAlert {
    [self.helper
     presentConfirmInViewController:self
     title:lang(@"Trusted & Verified Certificate")
     body:lang(@"This certificate has been security verified as legitimate.")
     confirmButtonTitle:lang(@"Learn More")
     cancelButtonTitle:lang(@"Dimiss")
     confirmActionIsDestructive:NO
     dismissed:^(BOOL confirmed) {
         if (confirmed) {
             [[UIApplication sharedApplication] openURL:
              [NSURL URLWithString:@"https://www.grc.com/fingerprints.htm"]];
         }
     }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowValue"]) {
        [segue.destinationViewController loadValue:valueToInspect title:titleForValue];
    }
}

- (void) loadCertificate:(CHCertificate *)certificate {
    _certificate = certificate;
}

@end
