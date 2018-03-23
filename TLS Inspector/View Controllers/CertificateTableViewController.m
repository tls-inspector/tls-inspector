#import "CertificateTableViewController.h"
#import "CertificateTableRowSection.h"
#import "CertificateTableRowItem.h"
#import "InspectorListTableViewController.h"
#import "TitleValueTableViewCell.h"
#import "CertificateReminderManager.h"

@interface CertificateTableViewController ()

@property (strong, nonatomic) NSMutableArray<CertificateTableRowSection *> * sections;

@end

@implementation CertificateTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.sections = [NSMutableArray new];

    self.tableView.estimatedRowHeight = 85.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [uihelper applyStylesToNavigationBar:self.navigationController.navigationBar];

    [[UIMenuController sharedMenuController] setMenuItems: @[
                                                             [[UIMenuItem alloc] initWithTitle:l(@"Verify") action:@selector(verifyValue:)],
                                                             [[UIMenuItem alloc] initWithTitle:l(@"Share") action:@selector(shareValue:)]]];
    [[UIMenuController sharedMenuController] update];

    [self loadCertificate];
    subscribe(@selector(reloadCert), RELOAD_CERT_NOTIFICATION);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
}

- (void) reloadCert {
    self.sections = [NSMutableArray new];
    [self loadCertificate];
    [self.tableView reloadData];
}

- (void) loadCertificate {
    self.title = selectedCertificate.summary;

    // Subject
    CertificateTableRowSection * subjectSection = [CertificateTableRowSection sectionWithTitle:@"Subject"];
    NSMutableArray<CertificateTableRowItem *> * items = [self rowsFromNameObject:selectedCertificate.subject];
    if (selectedCertificate.extendedValidation) {
        [items addObject:[CertificateTableRowItem itemWithTitle:l(@"Extended Validation Authority") value:selectedCertificate.extendedValidationAuthority style:CertificateTableRowItemStyleExpandedValue]];
    }
    subjectSection.items = items;
    [self.sections addObject:subjectSection];

    // Issuer
    CertificateTableRowSection * issuerSection = [CertificateTableRowSection sectionWithTitle:@"Issuer"];
    issuerSection.items = [self rowsFromNameObject:selectedCertificate.issuer];
    [self.sections addObject:issuerSection];

    // Validity Period
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    CertificateTableRowSection * dateSection = [CertificateTableRowSection sectionWithTitle:@"Validity Period"];
    NSMutableArray<CertificateTableRowItem *> * dateItems = [NSMutableArray arrayWithArray:@[
                                                                                             [CertificateTableRowItem itemWithTitle:l(@"Not Valid Before") value:[dateFormatter stringFromDate:[selectedCertificate notBefore]] style:CertificateTableRowItemStyleBasicValue],
                                                                                             [CertificateTableRowItem itemWithTitle:l(@"Not Valid After") value:[dateFormatter stringFromDate:[selectedCertificate notAfter]] style:CertificateTableRowItemStyleBasicValue],
                                                                                             ]];
    dateSection.items = dateItems;
    [self.sections addObject:dateSection];

    // Key Usage
    CertificateTableRowSection * keyUsageSection = [CertificateTableRowSection sectionWithTitle:@"Key Usage"];
    NSMutableArray<NSString *> * keyUsage = [NSMutableArray arrayWithCapacity:selectedCertificate.keyUsage.count];
    NSMutableArray<CertificateTableRowItem *> * usageItems = [NSMutableArray new];
    for (NSString * usage in selectedCertificate.keyUsage) {
        [keyUsage addObject:[lang key:[NSString stringWithFormat:@"keyUsage::%@", usage]]];
    }
    if (keyUsage.count > 0) {
        [usageItems addObject:[CertificateTableRowItem itemWithTitle:@"Basic" value:[keyUsage componentsJoinedByString:@", "] style:CertificateTableRowItemStyleExpandedValue]];
    }
    NSMutableArray<NSString *> * extKeyUsage = [NSMutableArray arrayWithCapacity:selectedCertificate.extendedKeyUsage.count];
    for (NSString * usage in selectedCertificate.extendedKeyUsage) {
        [extKeyUsage addObject:[lang key:[NSString stringWithFormat:@"keyUsage::%@", usage]]];
    }
    if (extKeyUsage.count > 0) {
        [usageItems addObject:[CertificateTableRowItem itemWithTitle:@"Extended" value:[extKeyUsage componentsJoinedByString:@", "] style:CertificateTableRowItemStyleExpandedValue]];
    }
    keyUsageSection.items = usageItems;
    if (usageItems.count > 0) {
        [self.sections addObject:keyUsageSection];
    }

    // Public Key Info
    CertificateTableRowSection * publicKeySection = [CertificateTableRowSection sectionWithTitle:@"Public Key"];
    publicKeySection.items = @[
                               [CertificateTableRowItem itemWithTitle:l(@"Algorithm") value:[lang key:[NSString stringWithFormat:@"KeyAlgorithm::%@", selectedCertificate.publicKey.algroithm]] style:CertificateTableRowItemStyleBasicValue],
                               [CertificateTableRowItem itemWithTitle:l(@"Signature") value:[lang key:[NSString stringWithFormat:@"CertAlgorithm::%@", selectedCertificate.signatureAlgorithm]] style:CertificateTableRowItemStyleBasicValue],
                               [CertificateTableRowItem itemWithTitle:l(@"Size") value:[NSString stringWithFormat:@"%i", selectedCertificate.publicKey.bitLength] style:CertificateTableRowItemStyleBasicValue],
                               ];
    [self.sections addObject:publicKeySection];

    // Fingerprint
    CertificateTableRowSection * fingerprintSection = [CertificateTableRowSection sectionWithTitle:@"Fingerprints"];
    fingerprintSection.items = @[
                                 [CertificateTableRowItem itemWithTitle:@"SHA-256" value:selectedCertificate.SHA256Fingerprint style:CertificateTableRowItemStyleFixedValue],
                                 [CertificateTableRowItem itemWithTitle:@"SHA-1" value:selectedCertificate.SHA1Fingerprint style:CertificateTableRowItemStyleFixedValue],
                                 ];
    [self.sections addObject:fingerprintSection];

    // Subject Alt. Names
    if (selectedCertificate.subjectAlternativeNames.count > 0) {
        CertificateTableRowSection * sanSection = [CertificateTableRowSection sectionWithTitle:@"Subject Alternative Names"];
        sanSection.items = @[
                                     [CertificateTableRowItem itemWithTitle:@"View all alternative names" value:@"" style:CertificateTableRowItemStyleBasic],
                                     ];
        [self.sections addObject:sanSection];
    }
}

- (NSMutableArray<CertificateTableRowItem *> *) rowsFromNameObject:(CKNameObject *)name {
    NSMutableArray<CertificateTableRowItem *> * subjectItems = [NSMutableArray arrayWithCapacity:8];

    if (name.commonName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Subject::CN") value:name.commonName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.organizationalUnitName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Subject::OU") value:name.organizationalUnitName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.organizationName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Subject::O") value:name.organizationName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.localityName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Subject::L") value:name.localityName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.stateOrProvinceName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Subject::S") value:name.stateOrProvinceName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.countryName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Subject::C") value:l(nstrcat(@"Country::", name.countryName)) style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.emailAddress != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Subject::E") value:name.emailAddress style:CertificateTableRowItemStyleBasicValue]];
    }

    return subjectItems;
}

- (void) showActionSheet:(id)sender {
    [uihelper
     presentActionSheetInViewController:self
     attachToTarget:[ActionTipTarget targetWithBarButtonItem:sender]
     title:selectedCertificate.summary
     subtitle:nil
     cancelButtonTitle:[lang key:@"Cancel"]
     items:@[
             l(@"Share Certificate"),
             l(@"Add Certificate Expiry Reminder"),
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSData * pem = [selectedCertificate publicKeyAsPEM];
    if (pem) {
        NSString * fileName = format(@"/%@.pem", selectedCertificate.serialNumber);
        NSURL * fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        [pem writeToURL:fileURL atomically:YES];

        UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[fileURL]
                                                        applicationActivities:nil];
        activityController.popoverPresentationController.barButtonItem = sender;
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

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowList"]) {
        [(InspectorListTableViewController *)segue.destinationViewController setList:selectedCertificate.subjectAlternativeNames title:l(@"Subject Alt. Names")];
    }
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)idx {
    CertificateTableRowSection * section = self.sections[idx];
    return section.items.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)idx {
    CertificateTableRowSection * section = self.sections[idx];
    return l(section.title);
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)idx {
    CertificateTableRowSection * section = self.sections[idx];
    return l(section.footer);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CertificateTableRowSection * section = self.sections[indexPath.section];
    CertificateTableRowItem * row = section.items[indexPath.row];
    return [row cellForRowItem];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CertificateTableRowSection * section = self.sections[indexPath.section];
    if ([section.title isEqualToString:@"Subject Alternative Names"]) {
        [self performSegueWithIdentifier:@"ShowList" sender:nil];
    }
}

- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    } else if (action == @selector(shareValue:) || action == @selector(verifyValue:)) {
        CertificateTableRowSection * section = self.sections[indexPath.section];
        BOOL match = [section.title isEqualToString:@"Fingerprints"];
        NSLog(@"Section '%@' == 'Fingerprints'", section.title);
        return match;
    }

    return NO;
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
    } else if (action == @selector(shareValue:)) {
        TitleValueTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[cell.valueLabel.text]
                                                        applicationActivities:nil];
        activityController.popoverPresentationController.sourceView = cell;
        [self presentViewController:activityController animated:YES completion:nil];
    } else if (action == @selector(verifyValue:)) {
        TitleValueTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:l(@"Verify Value")
                                                                                 message:l(@"Enter the value to verify")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = l(@"Value");
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:l(@"Cancel")
                                                               style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:l(@"Verify")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             UITextField * inputField = alertController.textFields.firstObject;
                                                             [self compareValue:inputField.text withValue:cell.valueLabel.text];
                                                         }];

        [alertController addAction:cancelAction];
        [alertController addAction:okAction];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void) compareValue:(NSString *)left withValue:(NSString *)right {
    NSString * (^formatValue)(NSString *) = ^NSString *(NSString * unformattedValue) {
        return [[unformattedValue lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    };
    NSString * formattedCurrentValue = formatValue(left);
    NSString * formattedExpectedValue = formatValue(right);
    if ([formattedExpectedValue isEqualToString:formattedCurrentValue]) {
        [uihelper presentAlertInViewController:self title:l(@"Verified") body:l(@"Both values matched.") dismissButtonTitle:l(@"Dismiss") dismissed:nil];
    } else {
        [uihelper presentAlertInViewController:self title:l(@"Not Verified") body:l(@"Values do not match.") dismissButtonTitle:l(@"Dismiss") dismissed:nil];
    }
}

- (void) shareValue:(UIMenuItem *)sender { }

- (void) verifyValue:(UIMenuItem *)sender { }

@end
