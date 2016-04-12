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
    CertificateErrors
};

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = self.certificate.summary;
    self.cells = [NSMutableArray new];
    self.certErrors = [NSMutableArray new];
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
    if ([[self.certificate SHA1Fingerprint] isEqualToString:@"CE DE B5 AF 3F C0 F7 41 FB 61 7C 07 3C 77 D3 D1 A7 F7 26 C0"]) {
        [self.certErrors addObject:@{@"error": lang(@"Insecure Superfish (Lenovo) certificate.")}];
    }
    if ([[self.certificate SHA1Fingerprint] isEqualToString:@"CA 94 75 79 13 CD A4 1E B2 DE A0 EE 32 CA 31 FA 63 25 4F 1B"]) {
        [self.certErrors addObject:@{@"error": lang(@"Insecure eDellRoot certificate.")}];
    }

    MD5Fingerprint = [self.certificate MD5Fingerprint];
    SHA1Fingerprint = [self.certificate SHA1Fingerprint];
    SHA256Fingerprint = [self.certificate SHA256Fingerprint];
    serialNumber = [self.certificate serialNumber];

    names = [self.certificate names];
}

# pragma mark -
# pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.certErrors.count <= 0) {
        return 3;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
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
        case CertificateInformation:
            return lang(@"Certificate Information");
        case Names:
            return lang(@"Subject Names");
        case Fingerprints:
            return lang(@"Fingerprints");
        case CertificateErrors:
            return lang(@"Certificate Errors");
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
    } else if (indexPath.section == Names) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDetail"];
        NSDictionary * data = [names objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = data[@"name"];
        cell.textLabel.text = lang(data[@"type"]);
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
        cell.tag = 1;
    } else if (indexPath.section == CertificateErrors) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
        NSDictionary * data = [self.certErrors objectAtIndex:indexPath.row];
        cell.textLabel.text = data[@"error"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 1) {
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
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowValue"]) {
        [segue.destinationViewController loadValue:valueToInspect title:titleForValue];
    }
}

@end
