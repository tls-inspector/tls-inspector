#import "CryptoOptionsTableViewController.h"

@interface CryptoOptionsTableViewController () <UITextFieldDelegate>

@end

@implementation CryptoOptionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (UserOptions.currentOptions.useOpenSSL) {
        return 2;
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"toggle" forIndexPath:indexPath];
        UILabel * label = [cell viewWithTag:10];
        label.text = l(@"Crypto Engine");
        label.textColor = themeTextColor;
        UISegmentedControl * toggle = [cell viewWithTag:20];
        [toggle setTitle:l(@"iOS") forSegmentAtIndex:0];
        [toggle setTitle:l(@"OpenSSL") forSegmentAtIndex:1];
        if (UserOptions.currentOptions.useOpenSSL) {
            [toggle setSelectedSegmentIndex:1];
        } else {
            [toggle setSelectedSegmentIndex:0];
        }
        [toggle addTarget:self action:@selector(engineSwitch:) forControlEvents:UIControlEventValueChanged];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"input" forIndexPath:indexPath];
        UILabel * label = [cell viewWithTag:10];
        label.text = l(@"Ciphers");
        label.textColor = themeTextColor;
        UITextField * input = [cell viewWithTag:20];
        input.placeholder = @"HIGH:!aNULL:!MD5:!RC4";
        input.text  = UserOptions.currentOptions.preferredCiphers;
        [input addTarget:self action:@selector(cipherEdit:) forControlEvents:UIControlEventEditingChanged];
        input.delegate = self;
        input.textColor = themeTextColor;
        input.keyboardAppearance = usingLightTheme ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark;
    }

    return cell;
}

- (void) engineSwitch:(UISegmentedControl *)sender {
    UserOptions.currentOptions.useOpenSSL = sender.selectedSegmentIndex == 1;
    if (UserOptions.currentOptions.useOpenSSL) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return l(@"Changing the crypto engine may result in TLS Inspector showing different connection information than what is used by your iOS device.");
    }

    return nil;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (void) cipherEdit:(UITextField *)sender {
    UserOptions.currentOptions.preferredCiphers = sender.text;
}

@end
