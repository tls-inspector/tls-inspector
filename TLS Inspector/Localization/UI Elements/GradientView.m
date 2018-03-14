#import "GradientView.h"

@implementation GradientView

- (void) drawRect:(CGRect)rect {
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)self.firstColor.CGColor, (id)self.secondColor.CGColor];
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(1, 0);
    [self.layer insertSublayer:gradient atIndex:0];
    [super drawRect:rect];
}

@end

