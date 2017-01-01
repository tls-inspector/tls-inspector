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
#import "CertificateReminderManager.h"

@import EventKit;

@interface InspectorTableViewController()

@property (strong, nonatomic) CHCertificate  * certificate;
@property (strong, nonatomic) NSMutableArray * cells;
@property (strong, nonatomic) NSMutableArray * certErrors;
@property (strong, nonatomic) UIHelper       * helper;
@property (strong, nonatomic) NSString       * domain;

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
    SectionEnd
};

typedef NS_ENUM(NSInteger, CellTags) {
    CellTagValue = 1,
    CellTagSANS
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
    
    NSString * algorythm = l(nstrcat(@"CertAlgorithm::", [self.certificate algorithm]));
    
    [self.cells addObject:@{@"label": l(@"Issuer"), @"value": [self.certificate issuer]}];
    [self.cells addObject:@{@"label": l(@"Algorithm"), @"value": algorythm}];
    [self.cells addObject:@{@"label": l(@"Valid To"), @"value": [dateFormatter stringFromDate:[self.certificate notAfter]]}];
    [self.cells addObject:@{@"label": l(@"Valid From"), @"value": [dateFormatter stringFromDate:[self.certificate notBefore]]}];

    if (![self.certificate validIssueDate]) {
        [self.certErrors addObject:@{@"error": l(@"Certificate is expired or not valid yet.")}];
    }
    if ([[self.certificate algorithm] hasPrefix:@"sha1"]) {
        [self.certErrors addObject:@{@"error": l(@"Certificate uses insecure SHA1 algorithm.")}];
    }

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
    [[UIHelper sharedInstance]
     presentActionSheetInViewController:self
     attachToTarget:[ActionTipTarget targetWithBarButtonItem:sender]
     title:self.title
     subtitle:nil
     cancelButtonTitle:[lang key:@"Cancel"]
     items:@[
             l(@"Share Public Key"),
             l(@"Add Certificate Expiry Reminder")
     ]
     dismissed:^(NSInteger itemIndex) {
        if (itemIndex == 0) {
            [self sharePublicKey:sender];
        } else if (itemIndex == 1) {
            [self addCertificateExpiryReminder:sender];
        }
     }];
}

- (void) sharePublicKey:(UIBarButtonItem *)sender {
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
         title:l(@"Unable to share public key")
         body:l(@"We were unable to export the public key in PEM format.")
         dismissButtonTitle:l(@"Dismiss")
         dismissed:nil];
    }
}

- (void) addCertificateExpiryReminder:(UIBarButtonItem *)sender {
    [[UIHelper sharedInstance]
     presentActionSheetInViewController:self
     attachToTarget:[ActionTipTarget targetWithBarButtonItem:sender]
     title:l(@"Notification Date")
     subtitle:l(@"How soon before the certificate expires should we notify you?")
     cancelButtonTitle:l(@"Cancel")
     items:@[
             lv(@"{count} weeks", @[@"2"]),
             l(@"1 month"),
             lv(@"{count} months", @[@"3"]),
             lv(@"{count} months", @[@"6"])]
     dismissed:^(NSInteger itemIndex) {
         if (itemIndex != -1) {
             NSUInteger days = 0;
             
             switch (itemIndex) {
                 case 0:
                     days = 14;
                     break;
                 case 1:
                     days = 30;
                     break;
                 case 2:
                     days = 60;
                     break;
                 case 3:
                     days = 180;
                     break;
                 default:
                     break;
             }
             
             [[CertificateReminderManager new]
              addReminderForCertificate:self.certificate
              forDomain:self.domain
              daysBeforeExpires:days
              completed:^(NSError *error, BOOL success) {
                  if (success) {
                      [self.helper
                       presentAlertInViewController:self
                       title:l(@"Reminder Added")
                       body:l(@"You can modify the reminder in the reminders app.")
                       dismissButtonTitle:l(@"Dismiss")
                       dismissed:nil];
                  } else if (error) {
                      [self.helper
                       presentErrorInViewController:self
                       error:error
                       dismissed:nil];
                  }
                  // If reminder permission was denied, success = NO and error = Nil
              }];
         }
     }];
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
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SubjectAltNames:
            return self.certificate.subjectAlternativeNames.count > 0 ? l(@"Subject Alternative Names") : nil;
        case CertificateInformation:
            return l(@"Certificate Information");
        case Names:
            return l(@"Subject Names");
        case Fingerprints:
            return l(@"Fingerprints");
        case CertificateErrors:
            return self.certErrors.count > 0 ? l(@"Certificate Errors") : nil;
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
                value = l(langKey);
            }

            detailTextLabel.text = value;
            textLabel.text = l(nstrcat(@"Subject::", key));
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
            cell.textLabel.text = l(@"View all alternate names");
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
        } case CellTagSANS: {
            [self performSegueWithIdentifier:@"ShowList" sender:nil];
            break;
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowValue"]) {
        [segue.destinationViewController loadValue:valueToInspect title:titleForValue];
    } else if ([segue.identifier isEqualToString:@"ShowList"]) {
        [(InspectorListTableViewController *)segue.destinationViewController setList:self.certificate.subjectAlternativeNames title:l(@"Subject Alt. Names")];
    }
}

- (void) loadCertificate:(CHCertificate *)certificate forDomain:(NSString *)domain {
    _certificate = certificate;
    _domain = domain;
}

@end
