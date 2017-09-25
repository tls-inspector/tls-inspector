#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@interface IconTableViewCell : UITableViewCell

@property (strong, nonatomic, readonly) UILabel * iconLabel;
@property (strong, nonatomic, readonly) UILabel * titleLabel;

- (id) initWithIcon:(FAIcon)icon color:(UIColor *)color title:(NSString *)title;

@end
