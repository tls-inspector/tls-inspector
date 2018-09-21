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
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = title;
        [self addSubview:self.titleLabel];

		[[self.titleLabel.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor] setActive:YES];
		[[self.titleLabel.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor] setActive:YES];
    }

    {
        // Add value label
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 36, 343, 21)];
        self.valueLabel.textAlignment = NSTextAlignmentLeft;
        self.valueLabel.numberOfLines = 0;
        self.valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.valueLabel.text = value;
        [self addSubview:self.valueLabel];
		
		[[self.valueLabel.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor] setActive:YES];
		[[self.valueLabel.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor]  setActive:YES];
		[[self.valueLabel.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor] setActive:YES];
    }
	
	NSLayoutConstraint *verticalSpacing = [NSLayoutConstraint constraintWithItem:self.valueLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
	[self addConstraint:verticalSpacing];

    [self.titleLabel setNeedsLayout];
    [self.valueLabel setNeedsLayout];
    [self setNeedsLayout];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setAppearance];

    return self;
}

- (void) setAppearance {
    if (usingLightTheme) {
        self.titleLabel.textColor = [UIColor darkGrayColor];
        self.valueLabel.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.valueLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithRed:0.106 green:0.157 blue:0.212 alpha:1.0];
    }
}

@end
