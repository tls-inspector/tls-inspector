#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@interface IconTableViewCell : UITableViewCell

@property (strong, nonatomic, readonly) UILabel * iconLabel;
@property (strong, nonatomic, readonly) UILabel * titleLabel;

- (id) initWithIcon:(FAIcon)icon title:(NSString *)title;

@end
