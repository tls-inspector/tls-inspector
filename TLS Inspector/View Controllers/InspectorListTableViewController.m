#import "InspectorListTableViewController.h"

@interface InspectorListTableViewController ()

@property (strong, nonatomic) NSArray * items;
@property (strong, nonatomic) NSString * viewTitle;

@end

@implementation InspectorListTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = self.viewTitle;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setList:(NSArray *)array title:(NSString *)title {
    _items = array;
    _viewTitle = title;
}

#pragma mark - Table view data source

- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void) tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.textLabel.text];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];

    cell.textLabel.text = self.items[indexPath.row];
    cell.textLabel.textColor = themeTextColor;

    return cell;
}

@end
