#import "ActionTipTarget.h"

@implementation ActionTipTarget

+ (ActionTipTarget *) targetWithView:(UIView *)view {
    ActionTipTarget * target = [ActionTipTarget new];
    target.targetView = view;
    return target;
}

+ (ActionTipTarget *) targetWithBarButtonItem:(UIBarButtonItem *)barButtonItem {
    ActionTipTarget * target = [ActionTipTarget new];
    target.targetBarButtonItem = barButtonItem;
    return target;
}

@end
