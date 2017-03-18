#import "GTAppLinks.h"
#import "UIDevice+PlatformString.h"
@import StoreKit;
@import MessageUI;

@interface GTAppLinks() <SKStoreProductViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    void (^dismissedBlock)();
}

@property (strong, nonatomic) UIViewController * viewController;

@end

@implementation GTAppLinks

- (void) showAppInAppStore:(GTAppStoreID)appID inViewController:(UIViewController *)viewController dismissed:(void(^)())dismissed {
    SKStoreProductViewController * productViewController = [SKStoreProductViewController new];
    productViewController.delegate = self;
    NSString * appIDString = [NSString stringWithFormat:@"%lu", appID];
    [productViewController loadProductWithParameters:@{
                                                       SKStoreProductParameterITunesItemIdentifier:
                                                           appIDString}
                                     completionBlock:nil];
    self.viewController = viewController;
    [viewController presentViewController:productViewController animated:YES completion:nil];
    dismissedBlock = dismissed;
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    if (viewController) {
        [self.viewController dismissViewControllerAnimated:YES completion:^{
            if (dismissedBlock) {
                dismissedBlock();
            }
        }];
    } else {
        if (dismissedBlock) {
            dismissedBlock();
        }
    }
}

- (void) showEmailComposeSheetForApp:(NSString * _Nonnull)appName email:(NSString * _Nonnull)appSupportEmail inViewController:(UIViewController * _Nonnull)viewController dismissed:(void(^ _Nullable)())dismissed {
    MFMailComposeViewController * mailController = [MFMailComposeViewController new];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:[NSString stringWithFormat:@"%@ Feedback", appName]];
    [mailController setToRecipients:@[appSupportEmail]];

    NSDictionary * infoDict = [[NSBundle mainBundle] infoDictionary];

    NSString * bundleName = [[NSBundle mainBundle] bundleIdentifier];
    NSString * bundleVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSNumber * build = [infoDict objectForKey:@"CFBundleVersion"];
    NSString * bundleBuild = [NSString stringWithFormat:@"%i", [build intValue]];
    NSString * deviceName = [[UIDevice currentDevice] PlatformString];
    NSOperatingSystemVersion systemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSString * body = [NSString stringWithFormat:@"Please do not delete the following line:<br/>%@ %@ (%@) %@ %i.%i.%i",
                       bundleName, bundleVersion, bundleBuild, deviceName, systemVersion.majorVersion, systemVersion.minorVersion, systemVersion.patchVersion];
    [mailController setMessageBody:[NSString stringWithFormat:@"<p><br/><br/></p><hr/><p><small>%@</small></p>", body] isHTML:YES];

    if (!mailController) {
        dismissed();
        return;
    }

    dismissedBlock = dismissed;
    
    [viewController presentViewController:mailController animated:YES completion:nil];
    self.viewController = viewController;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (dismissedBlock) {
            dismissedBlock();
        }
    }];
}

@end
