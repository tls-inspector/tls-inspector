#import "ChangeIconTableViewController.h"

@interface ChangeIconTableViewController ()

@property (strong, nonatomic) NSArray<NSString *> * iconTitles;
@property (strong, nonatomic) NSArray<NSString *> * iconFileNames;

@end

@implementation ChangeIconTableViewController

- (void) viewDidLoad {
    self.iconTitles = @[
        @"Dark",
        @"Light",
        @"Really Dark",
        @"Pride",
        @"Trans",
    ];
    self.iconFileNames = @[
        @"IconDark",
        @"IconLight",
        @"IconReallyDark",
        @"IconPride",
        @"IconTrans",
    ];
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.iconTitles.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"IconCell" forIndexPath:indexPath];
    
    UILabel * label = [cell viewWithTag:10];
    label.text = [lang key:self.iconTitles[indexPath.row]];
    
    UIImageView * image = [cell viewWithTag:20];
    NSString * iconName = [NSString stringWithFormat:@"%@76x76", self.iconFileNames[indexPath.row]];
    image.image = [UIImage imageNamed:iconName];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[UIApplication sharedApplication] setAlternateIconName:self.iconFileNames[indexPath.row] completionHandler:nil];
}

@end
