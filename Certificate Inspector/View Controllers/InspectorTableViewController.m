//
//  InspectorTableViewController.m
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

#import "InspectorTableViewController.h"
#import "CHCertificate.h"
#import "ValueViewController.h"
#import "UIHelper.h"
#import "InspectorListTableViewController.h"

#ifdef MAIN_APP
#import "TrustedFingerprints.h"
#endif

@interface InspectorTableViewController()

@property (strong, nonatomic) CHCertificate  * certificate;
@property (strong, nonatomic) NSMutableArray * cells;
@property (strong, nonatomic) NSMutableArray * certErrors;
@property (strong, nonatomic) NSDictionary   * certVerification;
@property (strong, nonatomic) UIHelper       * helper;

@end

@implementation InspectorTableViewController {
    NSDictionary<NSString *, NSString *> * names;
    NSArray<NSString *> * nameKeys;
    NSString * MD5Fingerprint;
    NSString * SHA1Fingerprint;
    NSString * SHA256Fingerprint;
    NSString * serialNumber;

    NSString * valueToInspect;
    NSString * titleForValue;
}

typedef NS_ENUM(NSInteger, InspectorSection) {
    SectionStart,
    CertificateInformation,
    Names,
    Fingerprints,
    SubjectAltNames,
    CertificateErrors,
    CertificateVerification,
    SectionEnd
};

typedef NS_ENUM(NSInteger, CellTags) {
    CellTagValue = 1,
    CellTagVerified = 2,
    CellTagSANS = 3
};

typedef NS_ENUM(NSInteger, LeftDetailTag) {
    LeftDetailTagTextLabel = 10,
    LeftDetailTagDetailTextLabel = 20
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

#ifdef MAIN_APP
    NSDictionary * trustResults = [[TrustedFingerprints sharedInstance]
                                   dataForFingerprint:[[[self.certificate SHA1Fingerprint] uppercaseString]
                                                       stringByReplacingOccurrencesOfString:@" " withString:@""]];
    if (trustResults) {
        if (![[trustResults objectForKey:@"trust"] boolValue]) {
            [self.certErrors addObject:@{@"error": [trustResults objectForKey:@"description"]}];
        } else {
            self.certVerification = trustResults;
        }
    }
#endif

    MD5Fingerprint = [self.certificate MD5Fingerprint];
    SHA1Fingerprint = [self.certificate SHA1Fingerprint];
    SHA256Fingerprint = [self.certificate SHA256Fingerprint];
    serialNumber = [self.certificate serialNumber];
    
    [self.certificate subjectAlternativeNames];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                              target:self action:@selector(actionButton:)];
    
    names = [self.certificate names];
    nameKeys = [names allKeys];
}

- (void)actionButton:(UIBarButtonItem *)sender {
    NSData * pem = [self.certificate publicKeyAsPEM];
    if (pem) {
        NSString * fileName = format(@"/%@.pem", self.certificate.serialNumber);
        NSURL * fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        [pem writeToURL:fileURL atomically:YES];

        UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[fileURL]
                                                        applicationActivities:nil];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            activityController.popoverPresentationController.barButtonItem = sender;
        }
        [self presentViewController:activityController animated:YES completion:nil];
    } else {
        [self.helper
         presentAlertInViewController:self
         title:lang(@"Unable to share public key")
         body:lang(@"We were unable to export the public key in PEM format.")
         dismissButtonTitle:lang(@"Dismiss")
         dismissed:nil];
    }
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
    return SectionEnd - SectionStart;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SubjectAltNames:
            return self.certificate.subjectAlternativeNames.count > 0 ? 1 : 0;
        case CertificateInformation:
            return self.cells.count;
        case Names:
            return names.count;
        case Fingerprints:
            return 4;
        case CertificateErrors:
            return self.certErrors.count;
        case CertificateVerification:
            return self.certVerification ? 1 : 0;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SubjectAltNames:
            return self.certificate.subjectAlternativeNames.count > 0 ? lang(@"Subject Alternative Names") : nil;
        case CertificateInformation:
            return lang(@"Certificate Information");
        case Names:
            return lang(@"Subject Names");
        case Fingerprints:
            return lang(@"Fingerprints");
        case CertificateErrors:
            return self.certErrors.count > 0 ? lang(@"Certificate Errors") : nil;
        case CertificateVerification:
            return self.certVerification ? lang(@"Verified Certificate") : nil;
    }
    return @"";
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    
    switch (indexPath.section) {
        case CertificateInformation: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetail"];
            UILabel * detailTextLabel = [cell viewWithTag:LeftDetailTagDetailTextLabel];
            UILabel * textLabel = [cell viewWithTag:LeftDetailTagTextLabel];
            
            NSDictionary * data = [self.cells objectAtIndex:indexPath.row];
            detailTextLabel.text = data[@"value"];
            textLabel.text = data[@"label"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        } case Names: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetail"];
            UILabel * detailTextLabel = [cell viewWithTag:LeftDetailTagDetailTextLabel];
            UILabel * textLabel = [cell viewWithTag:LeftDetailTagTextLabel];

            NSString * key = [nameKeys objectAtIndex:indexPath.row];
            NSString * value = [names objectForKey:key];
            if ([key isEqualToString:@"C"]) {
                NSString * langKey = nstrcat(@"Country::", value);
                value = lang(langKey);
            }

            detailTextLabel.text = value;
            textLabel.text = lang(key);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        } case Fingerprints: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetail"];
            UILabel * detailTextLabel = [cell viewWithTag:LeftDetailTagDetailTextLabel];
            UILabel * textLabel = [cell viewWithTag:LeftDetailTagTextLabel];

            switch (indexPath.row) {
                case 0:
                    textLabel.text = @"SHA256";
                    detailTextLabel.text = SHA256Fingerprint;
                    break;
                case 1:
                    textLabel.text = @"SHA1";
                    detailTextLabel.text = SHA1Fingerprint;
                    break;
                case 2:
                    textLabel.text = @"MD5";
                    detailTextLabel.text = MD5Fingerprint;
                    break;
                case 3:
                    textLabel.text = @"Serial";
                    detailTextLabel.text = serialNumber;
                    break;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = CellTagValue;
            break;
        } case SubjectAltNames: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            cell.textLabel.text = lang(@"View all alternate names");
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = CellTagSANS;
            break;
        } case CertificateErrors: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            NSDictionary * data = [self.certErrors objectAtIndex:indexPath.row];
            cell.textLabel.text = data[@"error"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        } case CertificateVerification: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailButton"];
            cell.textLabel.text = self.certVerification[@"description"];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = CellTagVerified;
            break;
        } default: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
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
        } case CellTagSANS: {
            [self performSegueWithIdentifier:@"ShowList" sender:nil];
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
#ifdef MAIN_APP
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
#else
    [self.helper
     presentAlertInViewController:self
     title:lang(@"Trusted & Verified Certificate")
     body:lang(@"This certificate has been security verified as legitimate.")
     dismissButtonTitle:lang(@"Dimiss")
     dismissed:nil];
#endif
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowValue"]) {
        [segue.destinationViewController loadValue:valueToInspect title:titleForValue];
    } else if ([segue.identifier isEqualToString:@"ShowList"]) {
        [(InspectorListTableViewController *)segue.destinationViewController setList:self.certificate.subjectAlternativeNames title:lang(@"Subject Alt. Names")];
    }
}

- (void) loadCertificate:(CHCertificate *)certificate {
    _certificate = certificate;
}

@end
