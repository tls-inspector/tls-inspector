#import "GetterTableViewController.h"

@interface GetterTableViewController () <CKGetterDelegate> {
    BOOL errorLoading;
}

@property (strong, nonatomic) NSArray<NSString *> * items;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> * itemStatus;
@property (strong, nonatomic) CKGetter * infoGetter;

@end

@implementation GetterTableViewController

#define CERT_CELL @"Certificates"
#define SERV_CELL @"Server Info"

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAssert(self.url != nil, @"URL should not be nil");
    if (self.url == nil) {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }

    appState.getterViewController = self;

    self.infoGetter = [CKGetter newGetter];
    self.infoGetter.delegate = self;
    [self.infoGetter getInfoForURL:self.url];
    self.title = self.url.host;

    self.items = @[CERT_CELL, SERV_CELL];
    self.itemStatus = [NSMutableDictionary dictionaryWithDictionary:@{CERT_CELL: @"Loading", SERV_CELL: @"Loading"}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return errorLoading ? l(@"Finished") : l(@"Loading...");
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (errorLoading) {
        return lv(@"There were one or more errors while inspecting {host}", @[self.url.host]);
    }

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * pending = [self.items objectAtIndex:indexPath.row];
    NSString * status = [self.itemStatus objectForKey:pending];

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:status forIndexPath:indexPath];

    if ([status isEqualToString:@"Loading"]) {
        UIActivityIndicatorView * spinner = [cell viewWithTag:2];
        if (usingLightTheme) {
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        } else {
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        }
    }

    UILabel * label = [cell viewWithTag:1];
    label.text = l(pending);
    label.textColor = themeTextColor;
    return cell;
}

- (void) finishedGetter:(CKGetter *)getter {
    dispatch_async(dispatch_get_main_queue(), ^{
        currentChain = getter.chain;
        selectedCertificate = getter.chain.certificates[0];
        UIStoryboard * main = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UISplitViewController * split = [main instantiateViewControllerWithIdentifier:@"SplitView"];
        [self presentViewController:split animated:YES completion:nil];
    });
}

- (void) getter:(CKGetter *)getter gotCertificateChain:(CKCertificateChain *)chain {
    [self.itemStatus setValue:@"Done" forKey:CERT_CELL];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void) getter:(CKGetter *)getter gotServerInfo:(CKServerInfo * _Nonnull)serverInfo {
    [self.itemStatus setValue:@"Done" forKey:SERV_CELL];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void) getter:(CKGetter *)getter errorGettingCertificateChain:(NSError *)error {
    [self.itemStatus setValue:@"Error" forKey:CERT_CELL];
    errorLoading = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self showCloseButton];
    });
}

- (void) getter:(CKGetter *)getter errorGettingServerInfo:(NSError *)error {
    [self.itemStatus setValue:@"Error" forKey:SERV_CELL];
    errorLoading = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self showCloseButton];
    });
}

- (void) showCloseButton {
    if (self.navigationItem.leftBarButtonItem == nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissView:)];
    }
}

- (void) dismissView:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
