#import "IconTableViewCell.h"
#import "UIFont+FontAwesome.h"

@interface IconTableViewCell()

@property (strong, nonatomic, readwrite) UILabel * iconLabel;
@property (strong, nonatomic, readwrite) UILabel * titleLabel;

@end

@implementation IconTableViewCell

- (id) initWithIcon:(FAIcon)icon title:(NSString *)title {
    self = [super initWithFrame:CGRectMake(0, 0, 375, 44)];

    // Add Icon
    {
        self.iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 20, 20)];
        self.iconLabel.font = [UIFont fontAwesomeFontOfSize:23.0f];
        self.iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconLabel.text = [NSString fontAwesomeIconStringForEnum:icon];
        [self addSubview:self.iconLabel];

        NSDictionary * views = @{ @"icon": self.iconLabel };
        [NSLayoutConstraint
         activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-16-[icon(==20)]"
                              options:0
                              metrics:nil
                              views:views]];
        [NSLayoutConstraint
         activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-8-[icon(==20)]"
                              options:0
                              metrics:nil
                              views:views]];
    }

    // Add Value
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 11, 20, 20)];
        self.titleLabel.text = title;
        [self addSubview:self.titleLabel];

        NSDictionary * views = @{ @"title": self.titleLabel, @"icon": self.iconLabel };
        [NSLayoutConstraint
         activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:[icon]-8-[title]-8-|"
                              options:0
                              metrics:nil
                              views:views]];
        [NSLayoutConstraint
         activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-8-[title]-8-|"
                              options:0
                              metrics:nil
                              views:views]];
    }

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
    if (usingLightTheme) {
        self.titleLabel.textColor = [UIColor blackColor];
        self.iconLabel.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor whiteColor];
        self.iconLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithRed:0.106 green:0.157 blue:0.212 alpha:1.0];
    }
}

@end
