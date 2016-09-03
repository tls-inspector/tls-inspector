//
//  UIHelper.h
//  Certificate Inspector
//
//  GPLv3 License
//  Copyright (c) 2016 Ian Spence
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ActionTipTarget.h"

@interface UIHelper : NSObject

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
 *  @param target            Attach the action sheet to this target UIView or bar button item (iPad only)
 *  @param title             The sheet title
 *  @param subtitle          The sheet subtitle (iOS 8+ only)
 *  @param cancelButtonTitle The cancel button title
 *  @param items             An array of strings for the buttons
 *  @param dismissed         Called when the sheet was dismissed
 */
- (void) presentActionSheetInViewController:(UIViewController *)viewController
                             attachToTarget:(ActionTipTarget *)target
                                      title:(NSString *)title
                                   subtitle:(NSString *)subtitle
                          cancelButtonTitle:(NSString *)cancelButtonTitle
                                      items:(NSArray<NSString *> *)items
                                  dismissed:(void (^)(NSInteger itemIndex))dismissed;

/**
 *  Apply better styles to the given button
 *
 *  @param button The button to update
 *  @param color  The color of the outline and the text
 */
- (void) applyStylesToButton:(UIButton *)button withColor:(UIColor *)color;

@end
