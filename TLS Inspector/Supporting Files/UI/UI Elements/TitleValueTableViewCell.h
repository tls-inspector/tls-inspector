#import <UIKit/UIKit.h>

@interface TitleValueTableViewCell : UITableViewCell

@property (strong, nonatomic, readonly) UILabel * titleLabel;
@property (strong, nonatomic, readonly) UILabel * valueLabel;

- (id) initWithTitle:(NSString *)title value:(NSString *)value;
- (void) useFixedWidthFont;

@end
