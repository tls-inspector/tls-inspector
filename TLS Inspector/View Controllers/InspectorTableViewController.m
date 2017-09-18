#import "InspectorTableViewController.h"
#import "ValueViewController.h"
#import "InspectorListTableViewController.h"
#import "CertificateReminderManager.h"
#import "DNSResolver.h"
#import "MBProgressHUD.h"
#import "TitleValueTableViewCell.h"
@import SafariServices;

@interface InspectorTableViewController()

@property (strong, nonatomic) NSMutableArray * cells;
@property (strong, nonatomic) NSMutableArray * certErrors;

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
    Algorithms,
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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                              target:self action:@selector(actionButton:)];

    self.tableView.estimatedRowHeight = 85.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [uihelper applyStylesToNavigationBar:self.navigationController.navigationBar];

    [self loadCertificate];
    subscribe(@selector(loadCertificate), RELOAD_CERT_NOTIFICATION);
}

- (void) loadCertificate {
    [selectedCertificate extendedValidation];

    self.title = selectedCertificate.summary;

    self.cells = [NSMutableArray new];
    self.certErrors = [NSMutableArray new];

    [self.cells addObject:@{@"label": l(@"Issuer"), @"value": [selectedCertificate issuer]}];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.cells addObject:@{@"label": l(@"Valid To"), @"value": [dateFormatter stringFromDate:[selectedCertificate notAfter]]}];
    [self.cells addObject:@{@"label": l(@"Valid From"), @"value": [dateFormatter stringFromDate:[selectedCertificate notBefore]]}];
    if (selectedCertificate.revoked.isRevoked && selectedCertificate.revoked.date != nil) {
        [self.cells addObject:@{@"label": l(@"Revoked On"), @"value": [dateFormatter stringFromDate:selectedCertificate.revoked.date]}];
    }
    if (selectedCertificate.isCA) {
        [self.cells addObject:@{@"label": l(@"Certificate Authority"), @"value": l(@"Yes")}];
    }

    NSString * evAuthority = [selectedCertificate extendedValidationAuthority];
    if (evAuthority) {
        [self.cells addObject:@{@"label": l(@"EV Authority"), @"value": evAuthority}];
    }

    if (![selectedCertificate validIssueDate]) {
        [self.certErrors addObject:@{@"label": @"Invalid Date", @"error": l(@"Certificate is expired or not valid yet.")}];
    }
    if ([[selectedCertificate signatureAlgorithm] hasPrefix:@"sha1"]) {
        if (currentChain.certificates.count > 1 && !selectedCertificate.isCA) {
            [self.certErrors addObject:@{@"label": @"Signature Algorithm", @"error": l(@"Certificate uses insecure SHA1 algorithm.")}];
        }
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

- (void) actionButton:(UIBarButtonItem *)sender {
    [uihelper
     presentActionSheetInViewController:self
     attachToTarget:[ActionTipTarget targetWithBarButtonItem:sender]
     title:self.title
     subtitle:nil
     cancelButtonTitle:[lang key:@"Cancel"]
     items:@[
             l(@"Share Certificate"),
             l(@"Add Certificate Expiry Reminder"),
             l(@"View on SSL Labs"),
             l(@"Search on Shodan")
             ]
     dismissed:^(NSInteger itemIndex) {
        if (itemIndex == 0) {
            [self sharePublicKey:sender];
        } else if (itemIndex == 1) {
            [self addCertificateExpiryReminder:sender];
        } else if (itemIndex == 2) {
            NSString * domain = currentChain.domain;
            // If the URL is lacking a protocol the host will be nil
            if (![domain hasPrefix:@"https://"]) {
                domain = nstrcat(@"https://", domain);
            }

            NSURL * url = [NSURL URLWithString:domain];
            [self openURL:nstrcat(@"https://www.ssllabs.com/ssltest/analyze.html?d=", url.host)];
        } else if (itemIndex == 3) {
            NSError * dnsError;
            NSArray<NSString *> * addresses = [DNSResolver resolveHostname:currentChain.domain error:&dnsError];
            if (addresses && addresses.count >= 1) {
                [self openURL:nstrcat(@"https://www.shodan.io/host/", addresses[0])];
            } else if (dnsError) {
                [uihelper presentErrorInViewController:self error:dnsError dismissed:nil];
            }
        }
     }];
}

- (void) openURL:(NSString *)url {
    SFSafariViewController * safariViewController = [[SFSafariViewController alloc]
                                                     initWithURL:[NSURL URLWithString:url]];
    [self presentViewController:safariViewController animated:YES completion:nil];
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
        [uihelper
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
    [uihelper
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
                      [uihelper
                       presentAlertInViewController:self
                       title:l(@"Reminder Added")
                       body:l(@"You can modify the reminder in the reminders app.")
                       dismissButtonTitle:l(@"Dismiss")
                       dismissed:nil];
                  } else if (error) {
                      [uihelper
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

- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void) tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString * data;
        if ([cell isKindOfClass:[TitleValueTableViewCell class]]) {
            data = ((TitleValueTableViewCell *)cell).valueLabel.text;
        } else {
            data = cell.detailTextLabel.text;
        }
        [[UIPasteboard generalPasteboard] setString:data];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:section];
    if (section == 0) {
        return UITableViewAutomaticDimension;
    }

    if (rows == 0) {
        return CGFLOAT_MIN;
    }

    return UITableViewAutomaticDimension;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:section];
    if (rows == 0) {
        return CGFLOAT_MIN;
    }

    return UITableViewAutomaticDimension;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionEnd - SectionStart;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SubjectAltNames:
            return selectedCertificate.subjectAlternativeNames.count > 0 ? 1 : 0;
        case CertificateInformation:
            return self.cells.count;
        case Algorithms:
            return 2;
        case Names:
            return names.count;
        case Fingerprints:
            return 4;
        case CertificateErrors:
            return self.certErrors.count;
    }
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SubjectAltNames:
            return selectedCertificate.subjectAlternativeNames.count > 0 ? l(@"Subject Alternative Names") : nil;
        case CertificateInformation:
            return l(@"Certificate Information");
        case Algorithms:
            return l(@"Algorithms");
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
            textLabel.textColor = colorForTheme([UIColor darkGrayColor], [UIColor lightGrayColor]);
            detailTextLabel.textColor = themeTextColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        } case Algorithms: {
            NSString * title, * value;
            if (indexPath.row == 0) {
                title = l(@"Signature");
                value = l(nstrcat(@"CertAlgorithm::", [selectedCertificate signatureAlgorithm]));
            } else if (indexPath.row == 1) {
                title = l(@"Key");
                value = [lang
                         key:@"{alg}, {len} bits"
                         args:@[
                                [lang
                                 key:[NSString
                                      stringWithFormat:@"%@%@", @"KeyAlgorithm::",
                                      selectedCertificate.publicKey.algroithm]],
                                [NSString
                                 stringWithFormat:@"%i",
                                 selectedCertificate.publicKey.bitLength]
                                ]];
            }
            return [[TitleValueTableViewCell alloc] initWithTitle:title value:value];
        } case Names: {
            NSString * key = [nameKeys objectAtIndex:indexPath.row];
            NSString * value = [names objectForKey:key];
            if ([key isEqualToString:@"C"]) {
                NSString * langKey = nstrcat(@"Country::", value);
                value = l(langKey);
            }

            return [[TitleValueTableViewCell alloc] initWithTitle:l(nstrcat(@"Subject::", key)) value:value];
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
            textLabel.textColor = colorForTheme([UIColor darkGrayColor], [UIColor lightGrayColor]);
            detailTextLabel.textColor = themeTextColor;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = CellTagValue;
            return cell;
        } case SubjectAltNames: {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
            cell.textLabel.text = l(@"View all alternate names");
            cell.textLabel.textColor = themeTextColor;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tag = CellTagSANS;
            return cell;
        } case CertificateErrors: {
            NSDictionary * data = [self.certErrors objectAtIndex:indexPath.row];
            TitleValueTableViewCell * cell = [[TitleValueTableViewCell alloc]
                                              initWithTitle:l(data[@"label"]) value:l(data[@"error"])];
            cell.userInteractionEnabled = NO;
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowValue"]) {
        [segue.destinationViewController loadValue:valueToInspect title:titleForValue];
    } else if ([segue.identifier isEqualToString:@"ShowList"]) {
        [(InspectorListTableViewController *)segue.destinationViewController setList:selectedCertificate.subjectAlternativeNames title:l(@"Subject Alt. Names")];
    }
}

@end
