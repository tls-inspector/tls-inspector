#import <UIKit/UIKit.h>

@interface TitleValueTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

- (CGFloat) heightForCell;

@end
