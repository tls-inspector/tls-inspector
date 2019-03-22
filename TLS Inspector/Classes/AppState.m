#import "AppState.h"

@implementation AppState

static AppState * _instance;

+ (AppState *) currentState {
    if (!_instance) {
        _instance = [AppState new];
    }
    return _instance;
}

- (id) init {
    if (!_instance) {
        _instance = [super init];

#if DEBUG
        [CertificateKit setLoggingLevel:CKLoggingLevelDebug];
#endif
    }
    return _instance;
}

- (BOOL) lightTheme {
    return UserOptions.currentOptions.useLightTheme;
}

- (void) setAppearance {
    if (!usingLightTheme) {
        // Style the navigation bar
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.141f green:0.204f blue:0.278f alpha:1.0f]];
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.114f green:0.631f blue:0.949f alpha:1.0f]];
        [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:0.141f green:0.204f blue:0.278f alpha:1.0f]];
        NSDictionary<NSAttributedStringDocumentAttributeKey, id> * attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        [[UINavigationBar appearance] setTitleTextAttributes:attributes];
        if (@available(iOS 11, *)) {
            [[UINavigationBar appearance] setLargeTitleTextAttributes:attributes];
        }

        // Style the tableview
        [[UITableView appearance] setBackgroundColor:[UIColor colorWithRed:0.08f green:0.11f blue:0.15f alpha:1.0f]];
        [[UITableView appearance] setSeparatorColor:[UIColor colorWithRed:0.16f green:0.23f blue:0.29f alpha:1.0f]];

        // Style the tableview cells
        [[UITableViewCell appearance] setBackgroundColor:[UIColor colorWithRed:0.106f green:0.157f blue:0.212f alpha:1.0f]];
        UIView *selectionView = [UIView new];
        selectionView.backgroundColor = [UIColor colorWithRed:0.08 green:0.12 blue:0.16 alpha:1.0];
        [[UITableViewCell appearance] setSelectedBackgroundView:selectionView];
        [[[UITableViewCell appearance] textLabel] setTextColor:[UIColor whiteColor]];
    } else {
        // Style the navigation bar
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.969f green:0.969f blue:0.969f alpha:1.0f]];
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.0f green:0.478431f blue:1.0f alpha:1.0f]];
        [[UINavigationBar appearance] setBackgroundColor:nil];

        NSDictionary<NSAttributedStringDocumentAttributeKey, id> * attributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
        [[UINavigationBar appearance] setTitleTextAttributes:attributes];
        if (@available(iOS 11, *)) {
            [[UINavigationBar appearance] setLargeTitleTextAttributes:attributes];
        }

        // Style the tableview
        [[UITableView appearance] setBackgroundColor:UIColor.groupTableViewBackgroundColor];
        [[UITableView appearance] setSeparatorColor:UIColor.lightGrayColor];

        // Style the tableview cells
        [[UITableViewCell appearance] setBackgroundColor:UIColor.whiteColor];
        UIView *selectionView = [UIView new];
        selectionView.backgroundColor = [UIColor colorWithRed:0.851f green:0.851f blue:0.851f alpha:0.851f];
        [[UITableViewCell appearance] setSelectedBackgroundView:selectionView];
        [[[UITableViewCell appearance] textLabel] setTextColor:UIColor.blackColor];
    }
}

@end
