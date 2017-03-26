#import "TitleValueTableViewCell.h"

@implementation TitleValueTableViewCell

- (CGFloat) heightForCell {
    float base = 70.0f;
    NSUInteger numberOfLines = [self lineCountForLabel:self.valueLabel];
    if (numberOfLines > 1) {
        return base + (10.0f * numberOfLines);
    } else {
        return base;
    }
}

- (NSUInteger) lineCountForLabel:(UILabel *)label {
    NSTextStorage * textStorage = [[NSTextStorage alloc] initWithString:label.text attributes:@{NSFontAttributeName: label.font}];
    
    // The labels width appears to always be the full width of the superview (cell) when this method is called
    // so we manually subtrack the padding of the label from the width
    float padding;
    if (isCompact) {
        padding = 16.0f;
    } else {
        padding = 12.0f;
    }
    CGFloat width = label.frame.size.width - padding;
    CGSize size = (CGSize){width, label.frame.size.height};
    NSTextContainer * textContainer = [[NSTextContainer alloc] initWithSize:size];
    textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    textContainer.maximumNumberOfLines = 0;
    textContainer.lineFragmentPadding = 0;
    
    NSLayoutManager * layoutManager = [NSLayoutManager new];
    layoutManager.textStorage = textStorage;
    [layoutManager addTextContainer:textContainer];
    
    NSUInteger numberOfLines = 0, index = 0;
    NSRange lineRange = NSMakeRange(0, 0);
    
    for (; index < layoutManager.numberOfGlyphs; numberOfLines++) {
        [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }
    
    return numberOfLines;
}

@end
