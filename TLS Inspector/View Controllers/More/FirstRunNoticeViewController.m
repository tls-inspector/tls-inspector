#import "FirstRunNoticeViewController.h"

@interface FirstRunNoticeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UITextView *noticeTextView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation FirstRunNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dismissButton.layer.cornerRadius = 5.0f;
    self.dismissButton.clipsToBounds = YES;
    self.dismissButton.backgroundColor = uihelper.blueColor;
    self.dismissButton.titleLabel.textColor = [UIColor whiteColor];

    self.iconLabel.textColor = colorForTheme(uihelper.blueColor, UIColor.whiteColor);
    self.view.backgroundColor = colorForTheme(UIColor.groupTableViewBackgroundColor, [UIColor colorWithRed:0.08f green:0.11f blue:0.15f alpha:1.0f]);

    NSMutableAttributedString * noticeText = [[NSMutableAttributedString alloc]
                                              initWithString:[lang key:@"first_run_notice"]
                                              attributes:@{
                                                           NSForegroundColorAttributeName: themeTextColor,
                                                           NSFontAttributeName: [UIFont systemFontOfSize:18.0f],
                                                           }];
    NSRange foundRange = [noticeText.mutableString rangeOfString:[lang key:@"Apple Support"]];
    [noticeText addAttribute:NSLinkAttributeName value:@"https://support.apple.com/" range:foundRange];
    [noticeText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18.0f] range:foundRange];

    self.noticeTextView.attributedText = noticeText;

    if (usingLightTheme) {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }
}

- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
