#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface UILabel (langLabel)
@property (nonatomic) IBInspectable NSString * textKey;
@end

IB_DESIGNABLE
@interface UIBarButtonItem (langBarButton)
@property (nonatomic) IBInspectable NSString * titleKey;
@end

IB_DESIGNABLE
@interface UIButton (langButton)
@property (nonatomic) IBInspectable NSString * defaultTitleKey;
@property (nonatomic) IBInspectable NSString * highLightedTitleKey;
@property (nonatomic) IBInspectable NSString * selectedTitleKey;
@property (nonatomic) IBInspectable NSString * disabledTitleKey;
@end

IB_DESIGNABLE
@interface UINavigationItem (langNavigationItem)
@property (nonatomic) IBInspectable NSString * titleKey;
@end

IB_DESIGNABLE
@interface UISearchBar (langSearchBar)
@property (nonatomic) IBInspectable NSString * placeholderKey;
@end

IB_DESIGNABLE
@interface UISegmentedControl (langSegmentedControl)
@property (nonatomic) IBInspectable NSString * titleKeyForIndex0;
@property (nonatomic) IBInspectable NSString * titleKeyForIndex1;
@property (nonatomic) IBInspectable NSString * titleKeyForIndex2;
@property (nonatomic) IBInspectable NSString * titleKeyForIndex3;
@property (nonatomic) IBInspectable NSString * titleKeyForIndex4;
@end

IB_DESIGNABLE
@interface UITabBarItem (langTabBarItem)
@property (nonatomic) IBInspectable NSString * titleKey;
@end

IB_DESIGNABLE
@interface UITextView (langTextView)
@property (nonatomic) IBInspectable NSString * textKey;
@end

IB_DESIGNABLE
@interface UIViewController (langViewController)
@property (nonatomic) IBInspectable NSString * titleKey;
@end
