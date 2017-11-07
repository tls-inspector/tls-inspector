#import "UIHelper.h"

@interface UIHelper () {
    void (^alertDismissedCallback)(NSInteger buttonIndex);
    void (^confirmDismissedCallback)(BOOL confirmed);
    void (^actionSheetDismissedCallback)(NSInteger buttonIndex);
}

@property (strong, nonatomic, readwrite) UIColor * greenColor;
@property (strong, nonatomic, readwrite) UIColor * redColor;
@property (strong, nonatomic, readwrite) UIColor * blueColor;

@end

@implementation UIHelper

static id _instance;

- (id) init {
    if (_instance == nil) {
        UIHelper * helper = [super init];
        helper.greenColor = [UIColor colorWithRed:0.298 green:0.686 blue:0.314 alpha:1];
        helper.redColor = [UIColor colorWithRed:0.957 green:0.263 blue:0.212 alpha:1];
        helper.blueColor = [UIColor colorWithRed:0.114 green:0.631 blue:0.949 alpha:1];
        _instance = helper;
    }
    return _instance;
}

+ (UIHelper *) sharedInstance {
    if (!_instance) {
        _instance = [UIHelper new];
    }
    return _instance;
}

- (void) presentAlertController:(UIAlertController *)alertController
               inViewController:(UIViewController *)viewController {
    if (![viewController.presentedViewController isKindOfClass:[UINavigationController class]]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if([viewController respondsToSelector:@selector(presentViewController:animated:completion:)]){
                [viewController presentViewController:alertController animated:YES completion:nil];
            }
        });
    }
}

- (void) presentAlertInViewController:(UIViewController *)viewController
                                title:(NSString *)title
                                 body:(NSString *)body
                   dismissButtonTitle:(NSString *)dismissButtonTitle
                            dismissed:(void (^)(NSInteger buttonIndex))dismissed {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
                                                                              message:body
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * dismissButton = [UIAlertAction actionWithTitle:dismissButtonTitle
                                                             style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                                                                 if (dismissed) {
                                                                     dismissed(0);
                                                                 }
                                                             }];
    [alertController addAction:dismissButton];
    [self presentAlertController:alertController inViewController:viewController];
}

- (void) presentErrorInViewController:(UIViewController *)viewController
                                error:(NSError *)error
                            dismissed:(void (^)(NSInteger buttonIndex))dismissed {
    [self presentAlertInViewController:viewController
                                 title:l(@"Uh oh!")
                                  body:error.localizedDescription
                    dismissButtonTitle:l(@"That sucks.")
                             dismissed:dismissed];
}

- (void) presentConfirmInViewController:(UIViewController *)viewController
                                  title:(NSString *)title
                                   body:(NSString *)body
                     confirmButtonTitle:(NSString *)confirmButtonTitle
                      cancelButtonTitle:(NSString *)cancelButtonTitle
             confirmActionIsDestructive:(BOOL)confirmActionIsDestructive
                              dismissed:(void (^)(BOOL confirmed))dismissed {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
                                                                              message:body
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * dismissButton = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                             style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                                                                 if (dismissed) {
                                                                     dismissed(NO);
                                                                 }
                                                             }];
    [alertController addAction:dismissButton];
    NSInteger style = confirmActionIsDestructive ? UIAlertActionStyleDestructive : UIAlertViewStyleDefault;
    UIAlertAction * confirmButton = [UIAlertAction actionWithTitle:confirmButtonTitle
                                                             style:style handler:^(UIAlertAction *action){
                                                                 if (dismissed) {
                                                                     dismissed(YES);
                                                                 }
                                                             }];
    [alertController addAction:confirmButton];
    [self presentAlertController:alertController inViewController:viewController];
}

- (void) presentActionSheetInViewController:(UIViewController *)viewController
                             attachToTarget:(ActionTipTarget *)target
                                      title:(NSString *)title
                                   subtitle:(NSString *)subtitle
                          cancelButtonTitle:(NSString *)cancelButtonTitle
                                      items:(NSArray<NSString *> *)items
                                  dismissed:(void (^)(NSInteger itemIndex))dismissed {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
                                                                              message:subtitle
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                            style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                                if (dismissed) {
                                                                    dismissed(-1);
                                                                }
                                                            }];
    [alertController addAction:cancelButton];
    [items enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction * button = [UIAlertAction actionWithTitle:obj
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                              if (dismissed) {
                                                                  dismissed(idx);
                                                              }
                                                          }];
        [alertController addAction:button];
    }];
    
    if (target.targetView) {
        alertController.popoverPresentationController.sourceView = target.targetView;
    }
    if (target.targetBarButtonItem) {
        alertController.popoverPresentationController.barButtonItem = target.targetBarButtonItem;
    }
    
    [self presentAlertController:alertController inViewController:viewController];
}

- (void) applyStylesToButton:(UIButton *)button withColor:(UIColor *)color {
    button.layer.borderWidth = 1;
    button.layer.borderColor = color.CGColor;
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
}

- (void) applyStylesToNavigationBar:(UINavigationBar *)navigationBar {
    if (usingLightTheme) {
        navigationBar.barStyle = UIBarStyleDefault;
        navigationBar.translucent = YES;
    } else {
        navigationBar.barStyle = UIBarStyleBlack;
        navigationBar.translucent = NO;
    }
}

@end
