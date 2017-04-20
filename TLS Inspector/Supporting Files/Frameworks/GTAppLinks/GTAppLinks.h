#import <Foundation/Foundation.h>

@interface GTAppLinks : NSObject

typedef NS_ENUM(NSUInteger, GTAppStoreID) {
    GTAppStoreIDVancityTransit = 946727302,
    GTAppStoreIDTLSInspector = 1100539810,
    GTAppStoreIDOrangeCloud = 1076061212
};

#define APP_SUPPORT_EMAIL_VANCITY_TRANSIT @"'Vancity Transit Project Manager' <vancity-transit@ecnepsnai.com>"
#define APP_SUPPORT_EMAIL_TLS_INSPECTOR @"'TLS Inspector Project Manager' <tls-inspector@ecnepsnai.com>"
#define APP_SUPPORT_EMAIL_ORANGE_CLOUD @"'Orange Cloud Project Manager' <orange-cloud@ecnepsnai.com>"
#define APP_NAME_VANCITY_TRANSIT @"Vancity Transit"
#define APP_NAME_TLS_INSPECTOR @"TLS Inspector"
#define APP_NAME_ORANGE_CLOUD @"Orange Cloud"

/**
 Show the given app ID in the current view controller.

 @param appID The app ID of the app to present.
 @param viewController The view controller to present on.
 @param dismissed Called when the view has been dismissed.
 */
- (void) showAppInAppStore:(GTAppStoreID)appID inViewController:(UIViewController * _Nonnull)viewController dismissed:(void(^ _Nullable)())dismissed;

/**
 Show the email compose sheet for the given app.

 @param appName The name of the current app. Use APP_NAME_X.
 @param appSupportEmail The support email of the current app. Use APP_SUPPORT_EMAIL_X.
 @param viewController The view controller to present on.
 @param dismissed Called when the view has been dismissed.
 */
- (void) showEmailComposeSheetForApp:(NSString * _Nonnull)appName email:(NSString * _Nonnull)appSupportEmail inViewController:(UIViewController * _Nonnull)viewController dismissed:(void(^ _Nullable)())dismissed;

@end
