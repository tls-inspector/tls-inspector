#import "CertificateListTableViewController.h"
#import "InspectorTableViewController.h"
#import "UIHelper.h"

@interface CertificateListTableViewController () {
    UIHelper * uihelper;
}

@property (weak, nonatomic) IBOutlet UIView * headerView;
@property (weak, nonatomic) IBOutlet UILabel * headerViewLabel;
@property (weak, nonatomic) IBOutlet UIButton * headerButton;

- (IBAction)headerButton:(id)sender;

@end

@implementation CertificateListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    uihelper = [UIHelper sharedInstance];
    
    if (currentChain.trusted) {
        self.headerViewLabel.text = l(@"Trusted Chain");
        self.headerView.backgroundColor = [UIColor colorWithRed:0.298 green:0.686 blue:0.314 alpha:1];
    } else {
        self.headerViewLabel.text = l(@"Untrusted Chain");
        self.headerView.backgroundColor = [UIColor colorWithRed:0.957 green:0.263 blue:0.212 alpha:1];
    }
    self.headerViewLabel.textColor = [UIColor whiteColor];
    self.headerButton.hidden = NO;

#ifdef EXTENSION
    [self.navigationItem
     setLeftBarButtonItem:[[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                           target:self
                           action:@selector(dismissView:)]];
#endif
    if (isRegular) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

#ifdef EXTENSION
- (void) dismissView:(id)sender {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}
#endif

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return currentChain.certificates.count > 0 ? l(@"Certificate Chain") : @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return currentChain.certificates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKCertificate * cert = [currentChain.certificates objectAtIndex:indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];

    if (cert.extendedValidation) {
        NSDictionary * names = [cert names];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@ [%@])", [cert summary], [names objectForKey:@"O"], [names objectForKey:@"C"]];
        cell.textLabel.textColor = self.headerView.backgroundColor = [UIColor colorWithRed:0.298 green:0.686 blue:0.314 alpha:1];
    } else {
        cell.textLabel.text = [cert summary];
        cell.textLabel.textColor = [UIColor whiteColor];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedCertificate = [currentChain.certificates objectAtIndex:indexPath.row];
    if (isRegular) {
        notify(RELOAD_CERT_NOTIFICATION);
    } else {
        UIViewController * inspectController = [self.storyboard instantiateViewControllerWithIdentifier:@"Inspector"];
        [self.navigationController pushViewController:inspectController animated:YES];
    }
}

- (IBAction)headerButton:(id)sender {
    NSString * title = currentChain.trusted ? l(@"Trusted Chain") : l(@"Untrusted Chain");
    NSString * body = currentChain.trusted ? l(@"trusted_chain_description") : l(@"untrusted_chain_description");
    [uihelper
     presentAlertInViewController:self
     title:title
     body:body
     dismissButtonTitle:l(@"Dismiss")
     dismissed:nil];
}

- (IBAction)closeButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
