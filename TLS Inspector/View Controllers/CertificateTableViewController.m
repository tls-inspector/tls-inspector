#import "CertificateTableViewController.h"
#import "CertificateTableRowSection.h"
#import "CertificateTableRowItem.h"
#import "InspectorListTableViewController.h"
#import "TitleValueTableViewCell.h"

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

    [self loadCertificate];
    subscribe(@selector(loadCertificate), RELOAD_CERT_NOTIFICATION);
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
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    CertificateTableRowSection * dateSection = [CertificateTableRowSection sectionWithTitle:@"Validity Period"];
    dateSection.items = @[
                            [CertificateTableRowItem itemWithTitle:l(@"Not Valid Before") value:[dateFormatter stringFromDate:[selectedCertificate notBefore]] style:CertificateTableRowItemStyleBasicValue],
                            [CertificateTableRowItem itemWithTitle:l(@"Not Valid After") value:[dateFormatter stringFromDate:[selectedCertificate notAfter]] style:CertificateTableRowItemStyleBasicValue],
                            ];
    [self.sections addObject:dateSection];

    // Key Usage
    CertificateTableRowSection * keyUsageSection = [CertificateTableRowSection sectionWithTitle:@"Key Usage"];
    NSMutableArray<NSString *> * keyUsage = [NSMutableArray arrayWithCapacity:selectedCertificate.keyUsage.count];
    for (NSString * usage in selectedCertificate.keyUsage) {
        [keyUsage addObject:[lang key:[NSString stringWithFormat:@"keyUsage::%@", usage]]];
    }
    NSMutableArray<NSString *> * extKeyUsage = [NSMutableArray arrayWithCapacity:selectedCertificate.extendedKeyUsage.count];
    for (NSString * usage in selectedCertificate.extendedKeyUsage) {
        [extKeyUsage addObject:[lang key:[NSString stringWithFormat:@"keyUsage::%@", usage]]];
    }
    keyUsageSection.items = @[
                                 [CertificateTableRowItem itemWithTitle:@"Basic" value:[keyUsage componentsJoinedByString:@", "] style:CertificateTableRowItemStyleExpandedValue],
                                 [CertificateTableRowItem itemWithTitle:@"Extended" value:[extKeyUsage componentsJoinedByString:@", "] style:CertificateTableRowItemStyleExpandedValue],
                                 ];
    [self.sections addObject:keyUsageSection];

    // Public Key Info
    CertificateTableRowSection * publicKeySection = [CertificateTableRowSection sectionWithTitle:@"Public Key"];
    publicKeySection.items = @[
                               [CertificateTableRowItem itemWithTitle:l(@"Algorithm") value:[lang key:[NSString stringWithFormat:@"KeyAlgorithm::%@", selectedCertificate.publicKey.algroithm]] style:CertificateTableRowItemStyleExpandedValue],
                                 [CertificateTableRowItem itemWithTitle:l(@"Size") value:[NSString stringWithFormat:@"%i", selectedCertificate.publicKey.bitLength] style:CertificateTableRowItemStyleExpandedValue],
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
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Common Name") value:name.commonName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.organizationalUnitName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Organizational Unit") value:name.organizationalUnitName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.organizationName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Organization") value:name.organizationName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.localityName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"City") value:name.localityName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.stateOrProvinceName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"State/Province") value:name.stateOrProvinceName style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.countryName != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"Country") value:l(nstrcat(@"Country::", name.countryName)) style:CertificateTableRowItemStyleBasicValue]];
    }

    if (name.emailAddress != nil) {
        [subjectItems addObject:[CertificateTableRowItem itemWithTitle:l(@"E-Mail Address") value:name.emailAddress style:CertificateTableRowItemStyleBasicValue]];
    }

    return subjectItems;
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

@end
