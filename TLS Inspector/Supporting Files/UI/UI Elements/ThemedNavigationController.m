#import "ThemedNavigationController.h"

@interface ThemedNavigationController ()

@end

@implementation ThemedNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self didChangeTheme];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didChangeTheme) name:CHANGE_THEME_NOTIFICATION object:nil];
}

- (void) didChangeTheme {
    if (ATLEAST_IOS_13) {
        [self.navigationBar setTranslucent:YES];
        [self setNeedsStatusBarAppearanceUpdate];
        return;
    }

    if (usingLightTheme) {
        [self.navigationBar setTranslucent:NO];
    } else {
        [self.navigationBar setTranslucent:NO];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    if (ATLEAST_IOS_13) {
        return UIStatusBarStyleDefault;
    }

    if (usingLightTheme) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

@end
