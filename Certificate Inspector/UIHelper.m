//
//  UIHelper.m
//  Certificate Inspector
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "UIHelper.h"

@interface UIHelper () {
    void (^alertDismissedCallback)(NSInteger buttonIndex);
    void (^confirmDismissedCallback)(BOOL confirmed);
    void (^actionSheetDismissedCallback)(NSInteger buttonIndex);
    void (^alertBannerTappedCallback)();
}

@end

@implementation UIHelper

static id _instance;
static bool alertControllerSupported;

- (id) init {
    if (_instance == nil) {
        UIHelper * uihelper = [super init];
        Class AlertControllerClass = NSClassFromString(@"UIAlertController");
        if (AlertControllerClass) {
            alertControllerSupported = YES;
        } else {
            alertControllerSupported = NO;
        }
        _instance = uihelper;
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
    if (alertControllerSupported) {
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
    } else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title
                                                             message:body delegate:self
                                                   cancelButtonTitle:dismissButtonTitle
                                                   otherButtonTitles:nil];
        alertDismissedCallback = dismissed;
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView show];
        });
    }
}

- (void) presentErrorInViewController:(UIViewController *)viewController
                                error:(NSError *)error
                            dismissed:(void (^)(NSInteger buttonIndex))dismissed {
    [self presentAlertInViewController:viewController
                                 title:lang(@"Uh oh!")
                                  body:error.localizedDescription
                    dismissButtonTitle:lang(@"That sucks.")
                             dismissed:dismissed];
}

- (void) presentConfirmInViewController:(UIViewController *)viewController
                                  title:(NSString *)title
                                   body:(NSString *)body
                     confirmButtonTitle:(NSString *)confirmButtonTitle
                      cancelButtonTitle:(NSString *)cancelButtonTitle
             confirmActionIsDestructive:(BOOL)confirmActionIsDestructive
                              dismissed:(void (^)(BOOL confirmed))dismissed {
    if (alertControllerSupported) {
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
    } else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title
                                                             message:body
                                                            delegate:self
                                                   cancelButtonTitle:cancelButtonTitle
                                                   otherButtonTitles:confirmButtonTitle, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView show];
        });
    }
}

- (void) presentActionSheetInViewController:(UIViewController *)viewController
                               attachToView:(UIView *)view
                                      title:(NSString *)title
                                   subtitle:(NSString *)subtitle
                          cancelButtonTitle:(NSString *)cancelButtonTitle
                                      items:(NSArray<NSString *> *)items
                                  dismissed:(void (^)(NSInteger itemIndex))dismissed {
    if (alertControllerSupported) {
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
        
        alertController.popoverPresentationController.sourceView = view;
        
        [self presentAlertController:alertController inViewController:viewController];
    } else {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                  delegate:self
                                                         cancelButtonTitle:cancelButtonTitle
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:nil];
        for (NSString * item in items) {
            [actionSheet addButtonWithTitle:item];
        }
        actionSheetDismissedCallback = dismissed;
        
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancelButtonTitle];
        dispatch_async(dispatch_get_main_queue(), ^{
            [actionSheet showInView:viewController.view];
        });
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheetDismissedCallback) {
        actionSheetDismissedCallback(buttonIndex);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertDismissedCallback) {
        alertDismissedCallback(buttonIndex);
        alertDismissedCallback = nil;
    } else if (confirmDismissedCallback) {
        confirmDismissedCallback(buttonIndex == 1 ? YES : NO);
        confirmDismissedCallback = nil;
    }
}

@end
