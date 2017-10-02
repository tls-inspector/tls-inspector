#import "MoreTableViewController.h"
#import "IconTableViewCell.h"

@interface MoreTableViewController ()

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [uihelper applyStylesToNavigationBar:self.navigationController.navigationBar];

    if (self.presentingViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close)];
    }
}

- (void) close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IconTableViewCell * cell;
    if (indexPath.row == 0) {
        cell = [[IconTableViewCell alloc] initWithIcon:FAInfoCircle color:uihelper.blueColor title:l(@"About TLS Inspector")];
    } else if (indexPath.row == 1) {
        cell = [[IconTableViewCell alloc] initWithIcon:FACog color:uihelper.blueColor title:l(@"Options")];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"AboutSegue" sender:nil];
    } else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"OptionsSegue" sender:nil];
    }
}

@end
