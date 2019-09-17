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
    
    UIImageView * imageView = [cell viewWithTag:20];
    NSString * iconName = [NSString stringWithFormat:@"%@", self.iconFileNames[indexPath.row]];
    UIImage * image = [UIImage imageNamed:iconName];
    if (image == nil) {
        NSLog(@"'%@'\tNO", iconName);
    } else {
        NSLog(@"'%@'\tYES", iconName);
    }
    imageView.image = image;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * name = self.iconFileNames[indexPath.row];
    NSLog(@"Setting app icon to '%@'", name);
    [[UIApplication sharedApplication] setAlternateIconName:name completionHandler:nil];
}

@end
