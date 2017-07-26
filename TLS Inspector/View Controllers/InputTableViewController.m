#import "InputTableViewController.h"
#import "CertificateListTableViewController.h"
#import "RecentDomains.h"
#import <CertificateKit/CertificateKit.h>
#import "TitleValueTableViewCell.h"
#import "GetterTableViewController.h"

@interface InputTableViewController() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSString * hostAddress;
    NSNumber * certIndex;
    NSString * placeholder;
    NSString * tip;
}

@property (strong, nonatomic) UITextField *hostField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *inspectButton;
- (IBAction) inspectButton:(UIBarButtonItem *)sender;
@property (strong, nonatomic) UIHelper * helper;
@property (strong, nonatomic) NSArray<NSString *> * recentDomains;
@property (strong, nonatomic) NSArray<NSString *> * placeholderDomains;
@property (strong, nonatomic) NSArray<NSString *> * tipKeys;

@end

@implementation InputTableViewController

#define tipSection(section) ![AppDefaults boolForKey:HIDE_TIPS] && section == 2
#define recentSection(section) (![AppDefaults boolForKey:HIDE_TIPS] && section == 3) || ([AppDefaults boolForKey:HIDE_TIPS] && section == 2)

- (void) viewDidLoad {
    [super viewDidLoad];
    self.helper = [UIHelper sharedInstance];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inspectWebsiteNotification:) name:INSPECT_NOTIFICATION object:nil];

    self.placeholderDomains = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DomainList" ofType:@"plist"]];
    self.tipKeys = @[
                     @"tlstip1",
                     @"tlstip2",
                     @"tlstip3",
                     @"tlstip4",
                     @"tlstip5",
                     @"tlstip6",
                     @"tlstip7"
                     ];

    self.tableView.estimatedRowHeight = 85.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSUInteger randomPlaceholderIndex = arc4random() % [self.placeholderDomains count];
    placeholder = [self.placeholderDomains objectAtIndex:randomPlaceholderIndex];
    NSUInteger randomTipIndex = arc4random() % [self.tipKeys count];
    tip = [self.tipKeys objectAtIndex:randomTipIndex];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.recentDomains = [[RecentDomains sharedInstance] getRecentDomains];
    [self.tableView reloadData];
    hostAddress = nil;
    certIndex = nil;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) hostFieldEdit:(id)sender {
    self.inspectButton.enabled = self.hostField.text.length > 0;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (self.hostField.text.length > 0) {
        hostAddress = self.hostField.text;
        [self inspectCertificate];
        return YES;
    } else {
        return NO;
    }
}

- (void) saveRecent {
    if ([RecentDomains sharedInstance].saveRecentDomains) {
        NSArray<NSString *> * domains = [[RecentDomains sharedInstance] getRecentDomains];
        if (![domains containsObject:hostAddress]) {
            self.recentDomains = [[RecentDomains sharedInstance] prependDomain:hostAddress];
            if ([self.tableView numberOfSections] == 3) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 1)] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (IBAction) inspectButton:(UIBarButtonItem *)sender {
    hostAddress = self.hostField.text;
    [self inspectCertificate];
}

- (void) inspectCertificate {
    NSString * lookupAddress = hostAddress;
    if (![lookupAddress hasPrefix:@"http"]) {
        lookupAddress = [NSString stringWithFormat:@"https://%@", lookupAddress];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hostField endEditing:YES];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });

    GetterTableViewController * getter = [self.storyboard instantiateViewControllerWithIdentifier:@"Getter"];
    getter.url = lookupAddress;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:getter] animated:YES completion:nil];
}

- (void) inspectWebsiteNotification:(NSNotification *)notification {
    NSDictionary<NSString *, id> * data = (NSDictionary *)notification.object;
    hostAddress = [data objectForKey:INSPECT_NOTIFICATION_HOST_KEY];
    [self inspectCertificate];
}

# pragma mark -
# pragma mark Table View

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (recentSection(indexPath.section)) {
        return YES;
    }
    return NO;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 1;
    if (![AppDefaults boolForKey:HIDE_TIPS]) {
        count ++;
    }
    if (self.recentDomains.count > 0) {
        count ++;
    }
    return count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (tipSection(section)) {
        return 1;
    } else if (recentSection(section)) {
        return self.recentDomains.count;
    }

    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return l(@"FQDN or IP Address");
    } else if (recentSection(section)) {
        return l(@"Recent Domains");
    }

    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return l(@"Enter the fully qualified domain name or IP address of the host you wish to inspect.  You can specify a port number here as well.");
    }
    return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Input" forIndexPath:indexPath];
        self.hostField = (UITextField *)[cell viewWithTag:1];
        [self.hostField addTarget:self action:@selector(hostFieldEdit:) forControlEvents:UIControlEventEditingChanged];
        self.hostField.delegate = self;
        self.hostField.textColor = themeTextColor;
        if (usingLightTheme) {
            self.hostField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{}];
        } else {
            UIColor *color = [UIColor colorWithRed:0.304f green:0.362f blue:0.48f alpha:1.0f];
            self.hostField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: color}];
        }
    } else if (tipSection(indexPath.section)) {
        TitleValueTableViewCell * tvCell = [[TitleValueTableViewCell alloc] initWithTitle:[lang key:@"Did You Know..."] value:[lang key:tip]];
        tvCell.valueLabel.font = [UIFont systemFontOfSize:13.0f];
        tvCell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        return tvCell;
    } else if (recentSection(indexPath.section)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
        cell.textLabel.text = [self.recentDomains objectAtIndex:indexPath.row];
        cell.textLabel.textColor = themeTextColor;
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.recentDomains = [[RecentDomains sharedInstance] removeDomainAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (recentSection(indexPath.section)) {
        hostAddress = self.recentDomains[indexPath.row];
        [self inspectCertificate];
    }

    return;
}

@end
