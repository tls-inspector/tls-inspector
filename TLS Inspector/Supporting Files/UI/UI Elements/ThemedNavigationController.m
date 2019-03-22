#import "ThemedNavigationController.h"

@interface ThemedNavigationController ()

@end

@implementation ThemedNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didChangeTheme) name:CHANGE_THEME_NOTIFICATION object:nil];
}

- (void) didChangeTheme {
    if (usingLightTheme) {
        [self.navigationBar setTranslucent:NO];
    } else {
        [self.navigationBar setTranslucent:NO];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    if (usingLightTheme) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

@end
