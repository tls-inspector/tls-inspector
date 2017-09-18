#import <Foundation/Foundation.h>

@interface GTAppLinks : NSObject

/**
 Show the given app ID in the current view controller.

 @param appID The app ID of the app to present.
 @param viewController The view controller to present on.
 @param dismissed Called when the view has been dismissed.
 */
- (void) showAppInAppStore:(uint32_t)appID inViewController:(UIViewController * _Nonnull)viewController dismissed:(void(^ _Nullable)(void))dismissed;

/**
 Show the email compose sheet for the given app.

 @param appName The name of the current app.
 @param appSupportEmail The support email of the current app.
 @param viewController The view controller to present on.
 @param dismissed Called when the view has been dismissed.
 */
- (void) showEmailComposeSheetForApp:(NSString * _Nonnull)appName email:(NSString * _Nonnull)appSupportEmail inViewController:(UIViewController * _Nonnull)viewController dismissed:(void(^ _Nullable)(void))dismissed;

@end
