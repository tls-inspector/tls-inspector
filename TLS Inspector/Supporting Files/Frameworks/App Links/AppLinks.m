#import "AppLinks.h"
#import "UIDevice+PlatformString.h"
@import StoreKit;
@import MessageUI;

@interface AppLinks() <SKStoreProductViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    void (^dismissedBlock)(void);
}

@property (strong, nonatomic) UIViewController * viewController;

@end

@implementation AppLinks

#define APP_LAUNCH_KEY @"__APP_LAUNCH_TIMES"
#define APP_LAUNCH_RATE_KEY @"__APP_LAUNCH_RATE"
#define APP_ID 1100539810
#define APP_NAME @"TLS Inspector"
#define APP_EMAIL @"'TLS Inspector Project Manager' <hello@tlsinspector.com>"

- (void) showAppInAppStorInViewController:(UIViewController *)viewController dismissed:(void (^)(void))dismissed {
    SKStoreProductViewController * productViewController = [SKStoreProductViewController new];
    productViewController.delegate = self;
    NSString * appIDString = [NSString stringWithFormat:@"%lu", (unsigned long)APP_ID];
    [productViewController loadProductWithParameters:@{
                                                       SKStoreProductParameterITunesItemIdentifier:
                                                           appIDString}
                                     completionBlock:nil];
    self.viewController = viewController;
    [viewController presentViewController:productViewController animated:YES completion:nil];
    dismissedBlock = dismissed;
}

- (void) appLaunchRate {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:APP_LAUNCH_RATE_KEY]) {
        NSNumber * launchTimesNumber = [defaults objectForKey:APP_LAUNCH_KEY];
        if (!launchTimesNumber) {
            launchTimesNumber = @1;
        }
        NSUInteger launchTimes = [launchTimesNumber unsignedIntegerValue];
        if (launchTimes > 2 && [SKStoreReviewController class]) {
            [SKStoreReviewController requestReview];
            [defaults setBool:YES forKey:APP_LAUNCH_RATE_KEY];
        }
        launchTimes++;
        [defaults setObject:[NSNumber numberWithUnsignedInteger:launchTimes] forKey:APP_LAUNCH_KEY];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    if (viewController) {
        [self.viewController dismissViewControllerAnimated:YES completion:^{
            if (self->dismissedBlock) {
                self->dismissedBlock();
            }
        }];
    } else {
        if (self->dismissedBlock) {
            self->dismissedBlock();
        }
    }
}

- (void) showEmailComposeSheetForAppInViewController:(UIViewController *)viewController withComments:(NSString *)comments includeLogs:(BOOL)includeLogs dismissed:(void (^)(void))dismissed {
    MFMailComposeViewController * mailController = [MFMailComposeViewController new];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:[NSString stringWithFormat:@"%@ Feedback", APP_NAME]];
    [mailController setToRecipients:@[APP_EMAIL]];

    NSDictionary * infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString * bundleName = [[NSBundle mainBundle] bundleIdentifier];
    NSString * bundleVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSNumber * build = [infoDict objectForKey:@"CFBundleVersion"];
    NSString * bundleBuild = [NSString stringWithFormat:@"%i", [build intValue]];
    NSString * gitRevision = GIT_REVISION;
    NSString * deviceName = [[UIDevice currentDevice] platformString];
    NSOperatingSystemVersion systemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSString * body = [NSString stringWithFormat:@"Please do not delete the following line:<br/>%@ %@ (%@ - %@) %@ %li.%li.%li",
                       bundleName, bundleVersion, bundleBuild, gitRevision, deviceName, (long)systemVersion.majorVersion, (long)systemVersion.minorVersion, (long)systemVersion.patchVersion];
    [mailController setMessageBody:[NSString stringWithFormat:@"<p>%@<br/><br/></p><hr/><p><small>%@</small></p>", (comments != nil ? comments : @""), body] isHTML:YES];

    if (includeLogs) {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        NSString * cklogPath = [documentsDirectory stringByAppendingPathComponent:@"CertificateKit.log"];
        NSData * logData = [NSData dataWithContentsOfFile:cklogPath];
        if (logData != nil) {
            [mailController addAttachmentData:logData mimeType:@"text/plain" fileName:@"TLS Inspector.log"];
        }
        NSString * exceptionsLogPath = [documentsDirectory stringByAppendingPathComponent:@"exceptions.log"];
        if ([NSFileManager.defaultManager fileExistsAtPath:exceptionsLogPath]) {
            NSData * exceptionData = [NSData dataWithContentsOfFile:exceptionsLogPath];
            if (exceptionData != nil) {
                [mailController addAttachmentData:exceptionData mimeType:@"text/plain" fileName:@"Exceptions.log"];
            }
        }
    }
    
    if (!mailController) {
        if (dismissed) {
            dismissed();
        }
        return;
    }

    dismissedBlock = dismissed;

    [viewController presentViewController:mailController animated:YES completion:nil];
    self.viewController = viewController;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (self->dismissedBlock) {
            self->dismissedBlock();
        }
    }];
}

@end
