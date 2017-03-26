#import "TitleValueTableViewCell.h"

@implementation TitleValueTableViewCell

- (CGFloat) heightForCell {
    float base = 70.0f;
    int numberOfLines = [self lineCountForLabel:self.valueLabel];
    if (numberOfLines > 1) {
        return base + (10.0f * numberOfLines);
    } else {
        return base;
    }
}

- (int) lineCountForLabel:(UILabel *)label {
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:@{NSFontAttributeName: label.font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    
    return (int)ceil(size.height / label.font.lineHeight);
}

@end
