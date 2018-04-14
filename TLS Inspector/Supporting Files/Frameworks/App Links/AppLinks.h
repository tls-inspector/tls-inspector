#import <Foundation/Foundation.h>

@interface AppLinks : NSObject

/**
 Show the current app in the current view controller.

 @param viewController The view controller to present on.
 @param dismissed Called when the view has been dismissed.
 */
- (void) showAppInAppStorInViewController:(UIViewController * _Nonnull)viewController dismissed:(void(^ _Nullable)(void))dismissed;

/**
 Show the app rate view if needed after app launch. Call this once the app has loaded and is idling.
 Will determine if the app has launched enough times to present the rate dialog.
 */
- (void) appLaunchRate;

/**
 Show the email compose sheet for the current app.

 @param viewController The view controller to present on.
 @param comments Optional comments to populate the email with
 @param dismissed Called when the view has been dismissed.
 */
- (void) showEmailComposeSheetForAppInViewController:(UIViewController * _Nonnull)viewController withComments:(NSString *)comments dismissed:(void(^ _Nullable)(void))dismissed;

@end
