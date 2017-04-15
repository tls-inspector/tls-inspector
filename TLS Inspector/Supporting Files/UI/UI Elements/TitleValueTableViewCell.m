#import "TitleValueTableViewCell.h"

@interface TitleValueTableViewCell ()

@property (strong, nonatomic, readwrite) UILabel * titleLabel;
@property (strong, nonatomic, readwrite) UILabel * valueLabel;

@end

@implementation TitleValueTableViewCell

- (id) initWithTitle:(NSString *)title value:(NSString *)value {
    self = [super initWithFrame:CGRectMake(0, 0, 375, 70)];

    {
        // Add title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 11, 36, 17)];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = title;
        [self addSubview:self.titleLabel];

        NSDictionary * views = @{ @"label": self.titleLabel };
        [NSLayoutConstraint
         activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-16-[label]"
                              options:0
                              metrics:nil
                              views:views]];
        [NSLayoutConstraint
         activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-8-[label]"
                              options:0
                              metrics:nil
                              views:views]];
    }

    {
        // Add value label
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 36, 343, 21)];
        self.valueLabel.textAlignment = NSTextAlignmentLeft;
        self.valueLabel.textColor = [UIColor whiteColor];
        self.valueLabel.numberOfLines = 0;
        self.valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.valueLabel.text = value;
        [self addSubview:self.valueLabel];

        NSDictionary * views = @{ @"title": self.titleLabel, @"value": self.valueLabel };
        [NSLayoutConstraint
         activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-16-[value]-16-|"
                              options:0
                              metrics:nil
                              views:views]];
        [NSLayoutConstraint
         activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:[title]-8-[value]-8-|"
                              options:0
                              metrics:nil
                              views:views]];
    }

    [self.titleLabel setNeedsLayout];
    [self.valueLabel setNeedsLayout];
    [self setNeedsLayout];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithRed:0.106 green:0.157 blue:0.212 alpha:1.0];

    return self;
}

@end
