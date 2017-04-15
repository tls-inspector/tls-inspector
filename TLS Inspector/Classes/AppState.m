#import "AppState.h"

@implementation AppState

static id _instance;

+ (AppState *) currentState {
    if (!_instance) {
        _instance = [AppState new];
    }
    return _instance;
}

- (id) init {
    if (!_instance) {
        _instance = [super init];
    }
    return _instance;
}

- (void) setAppearance {
    // Style the navigation bar
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.141f green:0.204f blue:0.278f alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.114f green:0.631f blue:0.949f alpha:1.0f]];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:0.141f green:0.204f blue:0.278f alpha:1.0f]];

    // Style the tableview
    [[UITableView appearance] setBackgroundColor:[UIColor colorWithRed:0.196f green:0.27f blue:0.329f alpha:1.0f]];
    [[UITableView appearance] setSeparatorColor:[UIColor colorWithRed:0.078f green:0.114f blue:0.149f alpha:1.0f]];

    // Style the tableview cells
    [[UITableViewCell appearance] setBackgroundColor:[UIColor colorWithRed:0.106f green:0.157f blue:0.212f alpha:1.0f]];
    UIView *selectionView = [UIView new];
    selectionView.backgroundColor = [UIColor colorWithRed:0.08 green:0.12 blue:0.16 alpha:1.0];
    [[UITableViewCell appearance] setSelectedBackgroundView:selectionView];
}

@end
