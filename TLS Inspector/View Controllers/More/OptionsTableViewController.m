#import "OptionsTableViewController.h"
#import "RecentDomains.h"

@interface OptionsTableViewController ()

@end

@implementation OptionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Remember Recent Lookups");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:[RecentDomains sharedInstance].saveRecentDomains];
            [toggle addTarget:self action:@selector(recentSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 1) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Show Tips");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.showTips];
            [toggle addTarget:self action:@selector(tipsSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 2) {
            UITableViewCell * toggleCell = [tableView dequeueReusableCellWithIdentifier:@"toggle" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[toggleCell viewWithTag:10];
            label.text = l(@"Theme");
            label.textColor = themeTextColor;
            UISegmentedControl * segment = (UISegmentedControl *)[toggleCell viewWithTag:20];
            [segment setTitle:[lang key:@"Dark"] forSegmentAtIndex:0];
            [segment setTitle:[lang key:@"Light"] forSegmentAtIndex:1];
            if (UserOptions.currentOptions.useLightTheme) {
                [segment setSelectedSegmentIndex:1];
            } else {
                [segment setSelectedSegmentIndex:0];
            }
            [segment addTarget:self action:@selector(themeSwitch:) forControlEvents:UIControlEventValueChanged];
            return toggleCell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Query OCSP Responder");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.queryOCSP];
            [toggle addTarget:self action:@selector(ocspSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        } else if (indexPath.row == 1) {
            UITableViewCell * switchCell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
            UILabel * label = (UILabel *)[switchCell viewWithTag:10];
            label.text = l(@"Download & Check CRL");
            label.textColor = themeTextColor;
            UISwitch * toggle = (UISwitch *)[switchCell viewWithTag:20];
            [toggle setOn:UserOptions.currentOptions.checkCRL];
            [toggle addTarget:self action:@selector(crlSwitch:) forControlEvents:UIControlEventTouchUpInside];
            return switchCell;
        }
    }
    return nil;
}

- (void) recentSwitch:(UISwitch *)sender {
    [RecentDomains sharedInstance].saveRecentDomains = sender.isOn;
}

- (void) tipsSwitch:(UISwitch *)sender {
    UserOptions.currentOptions.showTips = sender.isOn;
}

- (void) ocspSwitch:(UISwitch *)sender {
    UserOptions.currentOptions.queryOCSP = sender.isOn;
}

- (void) crlSwitch:(UISwitch *)sender {
    UserOptions.currentOptions.checkCRL = sender.isOn;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [lang key:@"General"];
    } else if (section == 1) {
        return [lang key:@"Certificate Status"];
    }
    
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return [lang key:@"certificate_status_footer"];
    }
    
    return nil;
}

- (void) themeSwitch:(UISegmentedControl *)sender {
    [uihelper
     presentConfirmInViewController:self
     title:l(@"Change Theme")
     body:l(@"You must restart the app for the change to take affect")
     confirmButtonTitle:l(@"Change")
     cancelButtonTitle:l(@"Cancel")
     confirmActionIsDestructive:NO
     dismissed:^(BOOL confirmed) {
         if (confirmed) {
             UserOptions.currentOptions.useLightTheme = sender.selectedSegmentIndex == 0;
             [appState setAppearance];
             UIAlertController * alert = [UIAlertController alertControllerWithTitle:l(@"Restart TLS Inspector") message:l(@"You must restart TLS Inspector for theme changes to take affect.") preferredStyle:UIAlertControllerStyleAlert];
             [self presentViewController:alert animated:YES completion:nil];
         } else {
             [sender setSelectedSegmentIndex:sender.selectedSegmentIndex == 0 ? 1 : 0];
         }
     }];
}

@end
