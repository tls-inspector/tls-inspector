#import "InitialNavigationController.h"

@interface InitialNavigationController ()

@end

@implementation InitialNavigationController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationBar.translucent = usingLightTheme;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    if (usingLightTheme) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

@end
