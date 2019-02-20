#import "HTTPHeadersTableViewController.h"
#import "TitleValueTableViewCell.h"

@interface HTTPHeadersTableViewController ()

@property (strong, nonatomic) NSArray<NSString *> * headerKeys;

@end

@implementation HTTPHeadersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headerKeys = self.headers.allKeys;
}

- (BOOL) tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (void) tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        TitleValueTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.valueLabel.text];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.headerKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * key = self.headerKeys[indexPath.row];
    NSString * value = self.headers[key];

    TitleValueTableViewCell * cell = [[TitleValueTableViewCell alloc] initWithTitle:key value:value];
    [cell useFixedWidthFont];

    return cell;
}
@end
