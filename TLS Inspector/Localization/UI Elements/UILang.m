#import "UILang.h"
#import "lang.h"

@implementation UILabel (langLabel)
- (NSString *) textKey { return @""; }
- (void) setTextKey:(NSString *)textKey {
    self.text = [lang key:textKey];
}
@end

@implementation UIBarButtonItem (langBarButton)
- (NSString *) titleKey { return @""; }
- (void) setTitleKey:(NSString *)titleKey {
    self.title = [lang key:titleKey];
}
@end

@implementation UIButton (langButton)
- (NSString *) defaultTitleKey { return @""; }
- (void) setDefaultTitleKey:(NSString *)defaultTitleKey {
    [self setTitle:defaultTitleKey forState:UIControlStateNormal];
}
- (NSString *) highLightedTitleKey { return @""; }
- (void) setHighLightedTitleKey:(NSString *)highLightedTitleKey {
    [self setTitle:highLightedTitleKey forState:UIControlStateHighlighted];
}
- (NSString *) selectedTitleKey { return @""; }
- (void) setSelectedTitleKey:(NSString *)selectedTitleKey {
    [self setTitle:selectedTitleKey forState:UIControlStateSelected];
}
- (NSString *) disabledTitleKey { return @""; }
- (void) setDisabledTitleKey:(NSString *)disabledTitleKey {
    [self setTitle:disabledTitleKey forState:UIControlStateDisabled];
}
@end

@implementation UINavigationItem (langNavigationItem)
- (NSString *) titleKey { return @""; }
- (void) setTitleKey:(NSString *)titleKey {
    self.title = [lang key:titleKey];
}
@end

@implementation UISearchBar (langSearchBar)
- (NSString *) placeholderKey { return @""; }
- (void) setPlaceholderKey:(NSString *)placeholderKey {
    self.placeholder = [lang key:placeholderKey];
}
@end

@implementation UISegmentedControl (langSegmentedControl)
- (NSString *) titleKeyForIndex0 { return @""; }
- (void) setTitleKeyForIndex0:(NSString *)titleKeyForIndex0 {
    [self setTitle:titleKeyForIndex0 forSegmentAtIndex:0];
}
- (NSString *) titleKeyForIndex1 { return @""; }
- (void) setTitleKeyForIndex1:(NSString *)titleKeyForIndex1 {
    [self setTitle:titleKeyForIndex1 forSegmentAtIndex:1];
}
- (NSString *) titleKeyForIndex2 { return @""; }
- (void) setTitleKeyForIndex2:(NSString *)titleKeyForIndex2 {
    [self setTitle:titleKeyForIndex2 forSegmentAtIndex:2];
}
- (NSString *) titleKeyForIndex3 { return @""; }
- (void) setTitleKeyForIndex3:(NSString *)titleKeyForIndex3 {
    [self setTitle:titleKeyForIndex3 forSegmentAtIndex:3];
}
- (NSString *) titleKeyForIndex4 { return @""; }
- (void) setTitleKeyForIndex4:(NSString *)titleKeyForIndex4 {
    [self setTitle:titleKeyForIndex4 forSegmentAtIndex:4];
}
@end

@implementation UITabBarItem (langTabBarItem)
- (NSString *) titleKey { return @""; }
- (void) setTitleKey:(NSString *)titleKey {
    self.title = [lang key:titleKey];
}
@end

@implementation UITextView (langTextView)
- (NSString *) textKey { return @""; }
- (void) setTextKey:(NSString *)textKey {
    [self setSelectable:YES];
    self.text = [lang key:textKey];
    [self setSelectable:NO];
}
@end

@implementation UIViewController (langViewController)
- (NSString *) titleKey { return @""; }
- (void) setTitleKey:(NSString *)titleKey {
    self.title = [lang key:titleKey];
}
@end
