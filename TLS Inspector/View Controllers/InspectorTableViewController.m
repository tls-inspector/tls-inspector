#import "InspectorTableViewController.h"
#import "ValueViewController.h"
#import "UIHelper.h"
#import "InspectorListTableViewController.h"
#import "CertificateReminderManager.h"
#import "DNSResolver.h"
#import "MBProgressHUD.h"
#import "TitleValueTableViewCell.h"

@interface InspectorTableViewController()

@property (strong, nonatomic) NSMutableArray * cells;
@property (strong, nonatomic) NSMutableArray * certErrors;
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

    self.helper = [UIHelper sharedInstance];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                              target:self action:@selector(actionButton:)];

    [self loadCertificate];
    subscribe(@selector(loadCertificate), RELOAD_CERT_NOTIFICATION);
}

- (void) loadCertificate {
    [selectedCertificate extendedValidation];

    self.title = selectedCertificate.summary;
    NSString * algorythm = l(nstrcat(@"CertAlgorithm::", [selectedCertificate algorithm]));

    self.cells = [NSMutableArray new];
    self.certErrors = [NSMutableArray new];

    [self.cells addObject:@{@"label": l(@"Issuer"), @"value": [selectedCertificate issuer]}];
    [self.cells addObject:@{@"label": l(@"Algorithm"), @"value": algorythm}];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.cells addObject:@{@"label": l(@"Valid To"), @"value": [dateFormatter stringFromDate:[selectedCertificate notAfter]]}];
    [self.cells addObject:@{@"label": l(@"Valid From"), @"value": [dateFormatter stringFromDate:[selectedCertificate notBefore]]}];

    NSString * evAuthority = [selectedCertificate extendedValidationAuthority];
    if (evAuthority) {
        [self.cells addObject:@{@"label": l(@"EV Authority"), @"value": evAuthority}];
    }

    if (![selectedCertificate validIssueDate]) {
        [self.certErrors addObject:@{@"error": l(@"Certificate is expired or not valid yet.")}];
    }
    if ([[selectedCertificate algorithm] hasPrefix:@"sha1"]) {
        [self.certErrors addObject:@{@"error": l(@"Certificate uses insecure SHA1 algorithm.")}];
    }

    MD5Fingerprint = [selectedCertificate MD5Fingerprint];
    SHA1Fingerprint = [selectedCertificate SHA1Fingerprint];
    SHA256Fingerprint = [selectedCertificate SHA256Fingerprint];
    serialNumber = [selectedCertificate serialNumber];

    [selectedCertificate subjectAlternativeNames];

    names = [selectedCertificate names];
    nameKeys = [names allKeys];

    [self.tableView reloadData];
}

- (void)actionButton:(UIBarButtonItem *)sender {
#ifdef MAIN_APP
    NSArray<NSString *> * items = @[
                                    l(@"Share Certificate"),
                                    l(@"Add Certificate Expiry Reminder"),
                                    l(@"View on SSL Labs"),
                                    l(@"Search on Shodan")
                                    ];
#else
    NSArray<NSString *> * items = @[
                                    l(@"Share Certificate"),
                                    l(@"Add Certificate Expiry Reminder")
                                    ];
#endif
    [[UIHelper sharedInstance]
     presentActionSheetInViewController:self
     attachToTarget:[ActionTipTarget targetWithBarButtonItem:sender]
     title:self.title
     subtitle:nil
     cancelButtonTitle:[lang key:@"Cancel"]
     items:items
     dismissed:^(NSInteger itemIndex) {
        if (itemIndex == 0) {
            [self sharePublicKey:sender];
        } else if (itemIndex == 1) {
            [self addCertificateExpiryReminder:sender];
#ifdef MAIN_APP
        } else if (itemIndex == 2) {
            NSURL * url = [NSURL URLWithString:currentChain.domain];
            open_url(nstrcat(@"https://www.ssllabs.com/ssltest/analyze.html?d=", url.host));
        } else if (itemIndex == 3) {
            NSError * dnsError;
            NSArray<NSString *> * addresses = [DNSResolver resolveHostname:currentChain.domain error:&dnsError];
            if (addresses && addresses.count >= 1) {
                open_url(nstrcat(@"https://www.shodan.io/host/", addresses[0]));
            } else if (dnsError) {
                [self.helper presentErrorInViewController:self error:dnsError dismissed:nil];
            }
#endif
        }
     }];
}

- (void) sharePublicKey:(UIBarButtonItem *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSData * pem = [selectedCertificate publicKeyAsPEM];
    if (pem) {
        NSString * fileName = format(@"/%@.pem", selectedCertificate.serialNumber);
        NSURL * fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        [pem writeToURL:fileURL atomically:YES];

        UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[fileURL]
                                                        applicationActivities:nil];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            activityController.popoverPresentationController.barButtonItem = sender;
        }
        [self presentViewController:activityController animated:YES completion:^() {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else {
        [self.helper
         presentAlertInViewController:self
         title:l(@"Unable to export certificate")
         body:l(@"We were unable to export the certificate in PEM format.")
         dismissButtonTitle:l(@"Dismiss")
         dismissed:^(NSInteger buttonIndex) {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }];
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
              addReminderForCertificate:selectedCertificate
              forDomain:currentChain.domain
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
            return selectedCertificate.subjectAlternativeNames.count > 0 ? 1 : 0;
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
            return selectedCertificate.subjectAlternativeNames.count > 0 ? l(@"Subject Alternative Names") : nil;
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
    switch (indexPath.section) {
        case CertificateInformation: {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetail"];
            UILabel * detailTextLabel = [cell viewWithTag:LeftDetailTagDetailTextLabel];
            UILabel * textLabel = [cell viewWithTag:LeftDetailTagTextLabel];
            
            NSDictionary * data = [self.cells objectAtIndex:indexPath.row];
            detailTextLabel.text = data[@"value"];
            textLabel.text = data[@"label"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        } case Names: {
            TitleValueTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TitleValue"];
            NSString * key = [nameKeys objectAtIndex:indexPath.row];
            NSString * value = [names objectForKey:key];
            if ([key isEqualToString:@"C"]) {
                NSString * langKey = nstrcat(@"Country::", value);
                value = l(langKey);
            }

            cell.titleLabel.text = l(nstrcat(@"Subject::", key));
            cell.valueLabel.text = value;
            return cell;
        } case Fingerprints: {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetail"];
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
            return cell;
        } case SubjectAltNames: {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            cell.textLabel.text = l(@"View all alternate names");
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = CellTagSANS;
            return cell;
        } case CertificateErrors: {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            NSDictionary * data = [self.certErrors objectAtIndex:indexPath.row];
            cell.textLabel.text = data[@"error"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        } default: {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
    }

    return nil;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case Names: {
            TitleValueTableViewCell * cell = (TitleValueTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
            return [cell heightForCell];
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowValue"]) {
        [segue.destinationViewController loadValue:valueToInspect title:titleForValue];
    } else if ([segue.identifier isEqualToString:@"ShowList"]) {
        [(InspectorListTableViewController *)segue.destinationViewController setList:selectedCertificate.subjectAlternativeNames title:l(@"Subject Alt. Names")];
    }
}

@end
