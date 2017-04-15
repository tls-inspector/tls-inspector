#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [[AppState currentState] setAppearance];
    return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSString * action = [url.host lowercaseString];
    if ([action isEqualToString:@"inspect"]) {
        NSString * host = [[url.path lowercaseString] substringFromIndex:1];
        NSArray<NSString *> * hostComponents = [host componentsSeparatedByString:@"/"];
        if (hostComponents.count == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:INSPECT_NOTIFICATION object:@{INSPECT_NOTIFICATION_HOST_KEY: host}];
        } else if (hostComponents.count == 2) {
            NSString * indexString = hostComponents[1];
            // Certificate index can only be integer (realistically between 0 and CKCertificate.CERTIFICATE_CHAIN_MAXIMUM)
            if ([indexString rangeOfString:@"^[0-9]+$" options:NSRegularExpressionSearch].location == NSNotFound) {
                NSLog(@"Invalid certificate index %@", indexString);
                return NO;
            }

            // Although this is an idex, its safe to use an integer here since the above validation prevents using
            // negitive values and we're later use this as an unsigned integer.
            NSNumber * index = [NSNumber numberWithInteger:[indexString integerValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:INSPECT_NOTIFICATION object:@{INSPECT_NOTIFICATION_HOST_KEY: hostComponents[0], INSPECT_NOTIFICATION_INDEX_KEY: index}];
        } else {
            NSLog(@"Invalid syntax (too many directories)");
            return NO;
        }
    }
    NSLog(@"Unknown action %@", action);
    return NO;
}

- (void) applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void) applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
