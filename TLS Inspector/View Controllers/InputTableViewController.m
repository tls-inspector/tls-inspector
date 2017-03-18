#import "InputTableViewController.h"
#import "CertificateListTableViewController.h"
#import "UIHelper.h"
#import "RecentDomains.h"
#import "CHCertificate.h"
#import "CHCertificateChain.h"

@interface InputTableViewController() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSString * hostAddress;
    NSNumber * certIndex;
}

@property (strong, nonatomic) UITextField *hostField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *inspectButton;
- (IBAction)inspectButton:(UIBarButtonItem *)sender;
@property (strong, nonatomic) UIHelper * helper;
@property (strong, nonatomic) NSArray<NSString *> * recentDomains;
@property (strong, nonatomic) CHCertificateChain * chain;

@end

@implementation InputTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.helper = [UIHelper sharedInstance];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.chain = [CHCertificateChain new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inspectWebsiteNotification:) name:INSPECT_NOTIFICATION object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.recentDomains = [[RecentDomains sharedInstance] getRecentDomains];
    [self.tableView reloadData];
    hostAddress = nil;
    certIndex = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"InspectCertificate"]) {
        [(CertificateListTableViewController *)[segue destinationViewController] setHost:hostAddress];
        if (certIndex) {
            [(CertificateListTableViewController *)[segue destinationViewController] setIndex:certIndex];
        }
    }
}

- (void)hostFieldEdit:(id)sender {
    self.inspectButton.enabled = self.hostField.text.length > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.hostField.text.length > 0) {
        [self saveRecent];
        hostAddress = self.hostField.text;
        [self inspectButton:nil];
        return YES;
    } else {
        return NO;
    }
}

- (void) saveRecent {
    if ([RecentDomains sharedInstance].saveRecentDomains) {
        self.recentDomains = [[RecentDomains sharedInstance] prependDomain:self.hostField.text];
        [self.tableView reloadData];
    }
}

- (IBAction) inspectButton:(UIBarButtonItem *)sender {
    [self saveRecent];
    hostAddress = self.hostField.text;
    
    if (![hostAddress hasPrefix:@"http"]) {
        hostAddress = [NSString stringWithFormat:@"https://%@", hostAddress];
    }
    
    [self.chain
     certificateChainFromURL:[NSURL URLWithString:hostAddress]
     finished:^(NSError * _Nullable error, CHCertificateChain * _Nullable chain) {
         if (error) {
             [[UIHelper sharedInstance]
              presentAlertInViewController:self
              title:l(@"Could not get certificates")
              body:error.localizedDescription
              dismissButtonTitle:l(@"Dismiss")
              dismissed:^(NSInteger buttonIndex) {
#ifdef MAIN_APP
                  [self.navigationController popViewControllerAnimated:YES];
#else
                  [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
#endif
              }];
         } else {
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
    self.hostField.text = [data objectForKey:INSPECT_NOTIFICATION_HOST_KEY];
    NSNumber * index = [data objectForKey:INSPECT_NOTIFICATION_INDEX_KEY];
    if (index) {
        certIndex = index;
    }
    [self inspectButton:nil];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;
    
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Input" forIndexPath:indexPath];
            self.hostField = (UITextField *)[cell viewWithTag:1];
            [self.hostField addTarget:self action:@selector(hostFieldEdit:) forControlEvents:UIControlEventEditingChanged];
            self.hostField.delegate = self;
            break;
        } case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
            cell.textLabel.text = [self.recentDomains objectAtIndex:indexPath.row];
            break;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    [self inspectButton:nil];
}
@end
