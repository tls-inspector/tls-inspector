#import "IconTableViewCell.h"
#import "UIFont+FontAwesome.h"

@interface IconTableViewCell()

@property (strong, nonatomic, readwrite) UILabel * iconLabel;
@property (strong, nonatomic, readwrite) UILabel * titleLabel;

@end

@implementation IconTableViewCell

- (id) initWithIcon:(FAIcon)icon color:(UIColor *)color title:(NSString *)title {
    self = [super initWithFrame:CGRectMake(0, 0, 375, 44)];

    // Add Icon
    {
        self.iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 20, 20)];
        self.iconLabel.font = [UIFont fontAwesomeFontOfSize:23.0f];
        self.iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconLabel.text = [NSString fontAwesomeIconStringForEnum:icon];
        self.iconLabel.textColor = color;
        [self addSubview:self.iconLabel];

        NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:self.iconLabel
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0f
                                                                             constant:20];
        NSLayoutConstraint * heightConstraint = [NSLayoutConstraint constraintWithItem:self.iconLabel
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:1.0f
                                                                              constant:20];
        NSLayoutConstraint * xConstraint = [NSLayoutConstraint constraintWithItem:self.iconLabel
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeLeftMargin
                                                                       multiplier:1.0f
                                                                         constant:8.0f];
        NSLayoutConstraint * yConstraint = [NSLayoutConstraint constraintWithItem:self.iconLabel
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0f
                                                                         constant:0];
        [NSLayoutConstraint activateConstraints:@[widthConstraint, heightConstraint, xConstraint, yConstraint]];
        self.iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }

    // Add Value
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 11, 20, 20)];
        self.titleLabel.text = title;
        if (!ATLEAST_IOS_13) {
            self.titleLabel.textColor = themeTextColor;
        }
        [self addSubview:self.titleLabel];

        NSLayoutConstraint * xConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.iconLabel
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0f
                                                                         constant:12.0f];
        NSLayoutConstraint * yConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0f
                                                                         constant:0];
        [NSLayoutConstraint activateConstraints:@[xConstraint, yConstraint]];
        [self.titleLabel sizeToFit];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }

    [self.heightAnchor constraintEqualToConstant:44.0f].active = YES;
    [self.iconLabel setNeedsLayout];
    [self.titleLabel setNeedsLayout];
    [self setNeedsLayout];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setAppearance];

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setAppearance {
    if (ATLEAST_IOS_13) {
        return;
    }
    self.backgroundColor = colorForTheme([UIColor whiteColor], [UIColor colorWithRed:0.106 green:0.157 blue:0.212 alpha:1.0]);
}

@end
