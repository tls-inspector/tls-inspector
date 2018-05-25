#import "SANListTableViewController.h"

@interface SANListTableViewController ()

@end

@implementation SANListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Left" forIndexPath:indexPath];
    
    cell.detailTextLabel.text = self.items[indexPath.row].value;
    cell.detailTextLabel.textColor = themeTextColor;

    NSString * type;
    switch (self.items[indexPath.row].type) {
        case AlternateNameTypeDNS:
            type = @"DNS";
            break;
        case AlternateNameTypeDirectory:
            type = @"Directory";
            break;
        case AlternateNameTypeEmail:
            type = @"Email";
            break;
        case AlternateNameTypeURI:
            type = @"URI";
            break;
        case AlternateNameTypeIP:
            type = @"IP";
            break;
        case AlternateNameTypeOther:
            type = @"Other";
            break;
    }

    cell.textLabel.text = [lang key:[NSString stringWithFormat:@"sanType::%@", type]];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    
    return cell;
}

@end
