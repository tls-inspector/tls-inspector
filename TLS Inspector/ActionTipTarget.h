#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ActionTipTarget : NSObject

@property (strong, nonatomic) UIView * targetView;
@property (strong, nonatomic) UIBarButtonItem * targetBarButtonItem;

+ (ActionTipTarget *) targetWithView:(UIView *)view;
+ (ActionTipTarget *) targetWithBarButtonItem:(UIBarButtonItem *)barButtonItem;

@end
