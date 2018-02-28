#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [UserOptions setDefaultValues];
    [[AppState currentState] setAppearance];
    return YES;
}

void uncaughtExceptionHandler(NSException *exception) {
    NSString * description = [NSString stringWithFormat:@"%@\n%@\n\n", exception.description, [exception.callStackSymbols componentsJoinedByString:@"\n"]];
    NSString * documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * path = [documentsDir stringByAppendingPathComponent:@"exceptions.log"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    NSFileHandle * file = [NSFileHandle fileHandleForWritingAtPath:path];
    
    [file seekToEndOfFile];
    [file writeData:[description dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

- (void) applicationWillResignActive:(UIApplication *)application { }

- (void) applicationDidEnterBackground:(UIApplication *)application { }

- (void) applicationWillEnterForeground:(UIApplication *)application { }

- (void) applicationDidBecomeActive:(UIApplication *)application { }

- (void) applicationWillTerminate:(UIApplication *)application { }

@end
