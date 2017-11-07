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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        [toggle setOn:![AppDefaults boolForKey:HIDE_TIPS]];
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
        if ([AppDefaults boolForKey:USE_LIGHT_THEME]) {
            [segment setSelectedSegmentIndex:1];
        } else {
            [segment setSelectedSegmentIndex:0];
        }
        [segment addTarget:self action:@selector(themeSwitch:) forControlEvents:UIControlEventValueChanged];
        return toggleCell;
    }
    return nil;
}

- (void) recentSwitch:(UISwitch *)sender {
    [RecentDomains sharedInstance].saveRecentDomains = sender.isOn;
}

- (void) tipsSwitch:(UISwitch *)sender {
    [AppDefaults setBool:!sender.isOn forKey:HIDE_TIPS];
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
             if (sender.selectedSegmentIndex == 0) {
                 [AppDefaults setBool:NO forKey:USE_LIGHT_THEME];
             } else {
                 [AppDefaults setBool:YES forKey:USE_LIGHT_THEME];
             }
             [appState setAppearance];
             UIAlertController * alert = [UIAlertController alertControllerWithTitle:l(@"Restart TLS Inspector") message:l(@"You must restart TLS Inspector for theme changes to take affect.") preferredStyle:UIAlertControllerStyleAlert];
             [self presentViewController:alert animated:YES completion:nil];
         } else {
             [sender setSelectedSegmentIndex:sender.selectedSegmentIndex == 0 ? 1 : 0];
         }
     }];
}

@end
