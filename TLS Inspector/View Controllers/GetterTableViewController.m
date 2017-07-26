#import "GetterTableViewController.h"

@interface GetterTableViewController () <CKGetterDelegate>

@property (strong, nonatomic) NSArray<NSString *> * items;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> * itemStatus;
@property (strong, nonatomic) CKGetter * infoGetter;

@end

@implementation GetterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.infoGetter = [CKGetter newGetter];
    self.infoGetter.delegate = self;
    [self.infoGetter getInfoForURL:[NSURL URLWithString:self.url]];
    self.title = self.url;

    self.items = @[@"Certificates", @"Server Info"];
    self.itemStatus = [NSMutableDictionary dictionaryWithDictionary:@{@"Certificates": @"Loading", @"Server Info": @"Loading"}];
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
    return l(@"Loading...");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * pending = [self.items objectAtIndex:indexPath.row];
    NSString * status = [self.itemStatus objectForKey:pending];

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:status forIndexPath:indexPath];
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
    [self.itemStatus setValue:@"Done" forKey:@"Certificates"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void) getter:(CKGetter *)getter gotServerInfo:(CKServerInfo * _Nonnull)serverInfo {
    [self.itemStatus setValue:@"Done" forKey:@"Server Info"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void) getter:(CKGetter *)getter errorGettingServerInfo:(NSError *)error {
    [self.itemStatus setValue:@"Error" forKey:@"Certificates"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void) getter:(CKGetter *)getter errorGettingCertificateChain:(NSError *)error {
    [self.itemStatus setValue:@"Error" forKey:@"Server Info"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
