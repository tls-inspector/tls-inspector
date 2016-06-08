//
//  UIHelper.h
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

#import <Foundation/Foundation.h>

@interface UIHelper : NSObject <UIActionSheetDelegate, UIAlertViewDelegate>

/**
 *  Return a shared instance of the UIHelper class
 *
 *  @return A UIHelper class
 */
+ (UIHelper *)sharedInstance;

/**
 *  Present an alert in the current view controller with only a dismiss button.
 *
 *  @param viewController     The view controller to present the alert on
 *  @param title              The alert title
 *  @param body               The alert body
 *  @param dismissButtonTitle The dismiss button title
 *  @param dismissed          Called when the alert was dismissed - the button index is not important
 */
- (void) presentAlertInViewController:(UIViewController *)viewController
                                title:(NSString *)title
                                 body:(NSString *)body
                   dismissButtonTitle:(NSString *)dismissButtonTitle
                            dismissed:(void (^)(NSInteger buttonIndex))dismissed;

/**
 *  Convenience method to present an alert with an NSError object
 *
 *  @param viewController The view controller to present the alert on
 *  @param error          The error itself
 *  @param dismissed      Called when the alert was dismissed - the button index is not important
 */
- (void) presentErrorInViewController:(UIViewController *)viewController
                                error:(NSError *)error
                            dismissed:(void (^)(NSInteger buttonIndex))dismissed;

/**
 *  Presents a confirmation dialog in the current view controller with two buttons.
 *
 *  @param viewController             The view controller to present the alert on
 *  @param title                      The alert title
 *  @param body                       The alert body
 *  @param confirmButtonTitle         The confirm button title
 *  @param cancelButtonTitle          The cancel button title
 *  @param confirmActionIsDestructive On iOS 8+ setting this to YES will make the confirm button red
 *  @param dismissed                  Called when the alert was dismissed
 */
- (void) presentConfirmInViewController:(UIViewController *)viewController
                                  title:(NSString *)title
                                   body:(NSString *)body
                     confirmButtonTitle:(NSString *)confirmButtonTitle
                      cancelButtonTitle:(NSString *)cancelButtonTitle
             confirmActionIsDestructive:(BOOL)confirmActionIsDestructive
                              dismissed:(void (^)(BOOL confirmed))dismissed;

/**
 *  Present an action sheet in the current view controller.
 *
 *  @param viewController    The view controller to present the alert on
 *  @param view              Attach the action sheet to this UIView (iPad only)
 *  @param title             The sheet title
 *  @param subtitle          The sheet subtitle (iOS 8+ only)
 *  @param cancelButtonTitle The cancel button title
 *  @param items             An array of strings for the buttons
 *  @param dismissed         Called when the sheet was dismissed
 */
- (void) presentActionSheetInViewController:(UIViewController *)viewController
                               attachToView:(UIView *)view
                                      title:(NSString *)title
                                   subtitle:(NSString *)subtitle
                          cancelButtonTitle:(NSString *)cancelButtonTitle
                                      items:(NSArray<NSString *> *)items
                                  dismissed:(void (^)(NSInteger itemIndex))dismissed;

@end
