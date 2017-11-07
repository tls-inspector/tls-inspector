#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[AppState currentState] setAppearance];
    return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application { }

- (void) applicationDidEnterBackground:(UIApplication *)application { }

- (void) applicationWillEnterForeground:(UIApplication *)application { }

- (void) applicationDidBecomeActive:(UIApplication *)application { }

- (void) applicationWillTerminate:(UIApplication *)application { }

@end
