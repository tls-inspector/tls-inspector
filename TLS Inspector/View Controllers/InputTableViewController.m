#import "InputTableViewController.h"
#import "CertificateListTableViewController.h"
#import "UIHelper.h"
#import "RecentDomains.h"
#import "MBProgressHUD.h"

@interface InputTableViewController() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSString * hostAddress;
    NSNumber * certIndex;
    NSString * placeholder;
}

@property (strong, nonatomic) UITextField *hostField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *inspectButton;
- (IBAction) inspectButton:(UIBarButtonItem *)sender;
@property (strong, nonatomic) UIHelper * helper;
@property (strong, nonatomic) NSArray<NSString *> * recentDomains;
@property (strong, nonatomic) CKCertificateChain * chain;
@property (strong, nonatomic) NSArray<NSString *> * placeholderDomains;

@end

@implementation InputTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.helper = [UIHelper sharedInstance];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.chain = [CKCertificateChain new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inspectWebsiteNotification:) name:INSPECT_NOTIFICATION object:nil];

    self.placeholderDomains = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DomainList" ofType:@"plist"]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSUInteger randomIndex = arc4random() % [self.placeholderDomains count];
    placeholder = [self.placeholderDomains objectAtIndex:randomIndex];
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
            if ([self.tableView numberOfSections] == 2) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [self.tableView beginUpdates];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
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

    [self.chain
     certificateChainFromURL:[NSURL URLWithString:lookupAddress]
     finished:^(NSError * _Nullable error, CKCertificateChain * _Nullable chain) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         });

         if (error) {
             NSString * description;
             switch (error.code) {
                case 61: // Still trying to find the enum def for this one
                     description = l(@"Connection refused.");
                     break;
                case kCFHostErrorUnknown:
                case kCFHostErrorHostNotFound:
                     description = l(@"Host was not found or invalid.");
                     break;
                case errSSLInternal:
                     description = l(@"Internal error.");
                     break;
                default:
                     description = error.localizedDescription;
                     break;
             }
             [[UIHelper sharedInstance]
              presentAlertInViewController:self
              title:l(@"An error occurred")
              body:description
              dismissButtonTitle:l(@"Dismiss")
              dismissed:nil];
         } else {
             [self saveRecent];
             dispatch_async(dispatch_get_main_queue(), ^{
                 currentChain = chain;
                 selectedCertificate = chain.certificates[0];
                 UISplitViewController * split = [self.storyboard instantiateViewControllerWithIdentifier:@"SplitView"];
                 [self presentViewController:split animated:YES completion:nil];
             });
         }
     }];
}

- (void) inspectWebsiteNotification:(NSNotification *)notification {
    NSDictionary<NSString *, id> * data = (NSDictionary *)notification.object;
    hostAddress = [data objectForKey:INSPECT_NOTIFICATION_HOST_KEY];
    [self inspectCertificate];
}

# pragma mark -
# pragma mark Table View

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            return YES;
        default:
            return NO;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.recentDomains.count > 0 ? 2 : 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.recentDomains.count;
        default:
            return 0;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return l(@"FQDN or IP Address");
        case 1:
            return l(@"Recent Domains");
        default:
            return nil;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return l(@"Enter the fully qualified domain name or IP address of the host you wish to inspect.  You can specify a port number here as well.");
        default:
            return nil;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;

    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Input" forIndexPath:indexPath];
            self.hostField = (UITextField *)[cell viewWithTag:1];
            [self.hostField addTarget:self action:@selector(hostFieldEdit:) forControlEvents:UIControlEventEditingChanged];
            self.hostField.delegate = self;
            UIColor *color = [UIColor colorWithRed:0.304f green:0.362f blue:0.48f alpha:1.0f];
            self.hostField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: color}];
            break;
        } case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
            cell.textLabel.text = [self.recentDomains objectAtIndex:indexPath.row];
            break;
        }
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
    if (indexPath.section != 1) {
        return;
    }

    hostAddress = self.recentDomains[indexPath.row];
    [self inspectCertificate];
}
@end
