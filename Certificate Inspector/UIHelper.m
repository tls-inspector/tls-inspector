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

@implementation UIHelper {
    void (^dismissedClosure)(NSInteger buttonIndex);
}

+ (UIHelper *) withViewController:(UIViewController *)viewController {
    UIHelper * helper = [UIHelper new];
    helper.viewController = viewController;
    return helper;
}

- (void) presentAlertWithTitle:(NSString *)title
                          body:(NSString *)body
            dismissButtonTitle:(NSString *)dismissButtonTitle
                     dismissed:(void (^)(NSInteger buttonIndex))dismissed {
    Class AlertControllerClass = NSClassFromString(@"UIAlertController");
    if(AlertControllerClass){
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * dismissButton = [UIAlertAction actionWithTitle:dismissButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (dismissed) {
                dismissed(0);
            }
        }];
        [alertController addAction:dismissButton];
        if (![self.viewController.presentedViewController isKindOfClass:[UINavigationController class]]){
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.viewController respondsToSelector:@selector(presentViewController:animated:completion:)]){
                    [self.viewController presentViewController:alertController animated:YES completion:nil];
                }
            });
        }
    } else {
        dismissedClosure = dismissed;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:dismissButtonTitle otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView show];
        });
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (dismissedClosure) {
        dismissedClosure(buttonIndex);
    }
}

- (void) presentAlertWithError:(NSError *)error
                         title:(NSString *)title
                     dismissed:(void (^)(NSInteger buttonIndex))dismissed {
    [self presentAlertWithTitle:title
                           body:error.localizedDescription
             dismissButtonTitle:NSLocalizedString(@"Dismiss", nil)
                      dismissed:^(NSInteger buttonIndex) {
        dismissed(buttonIndex);
    }];
}

- (void) presentActionSheetWithTitle:(NSString *)title
                            subtitle:(NSString *)subtitle
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                             choices:(NSArray<NSString *>*)choices
                           dismissed:(void (^)(NSInteger selectedIndex))dismissed {
    Class AlertControllerClass = NSClassFromString(@"UIAlertController");
    if(AlertControllerClass){
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
                                                                                  message:subtitle
                                                                           preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) {
                                                                  dismissed(-1);
                                                              }];
        [alertController addAction:cancelButton];
        for (int i = 0; i < choices.count; i ++) {
            NSString * item = [choices objectAtIndex:i];
            UIAlertAction * button = [UIAlertAction actionWithTitle:item
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                dismissed(i);
                                                            }];
            [alertController addAction:button];
        }
        if (![self.viewController.presentedViewController isKindOfClass:[UINavigationController class]]){
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.viewController respondsToSelector:@selector(presentViewController:animated:completion:)]){
                    [self.viewController presentViewController:alertController animated:YES completion:nil];
                }
            });
        }
    } else {
        dismissedClosure = dismissed;
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:nil];
        for(NSString * item in choices)  {
            [actionSheet addButtonWithTitle:item];
        }

        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancelButtonTitle];
        dispatch_async(dispatch_get_main_queue(), ^{
            [actionSheet showInView:self.viewController.view];
        });
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        dismissedClosure(buttonIndex);
    } else {
        dismissedClosure(-1);
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    dismissedClosure(-1);
}

@end
