#import "ContactSupportTableViewController.h"

@interface ContactSupportTableViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *descriptionInput;

@property (nonatomic) void (^feedbackFinished)(NSString *);

@end

@implementation ContactSupportTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    ADD_SET_THEME_WORKAROUND

    [uihelper applyStylesToNavigationBar:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(next:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (@available(iOS 13, *)) {
        self.descriptionInput.textColor = [UIColor labelColor];
    } else {
        self.descriptionInput.textColor = themeTextColor;
        self.descriptionInput.keyboardAppearance = usingLightTheme ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark;
    }
    
    if (!UserOptions.currentOptions.contactNagDismissed) {
        UIViewController * notice = [self.storyboard instantiateViewControllerWithIdentifier:@"Notice"];
        UINavigationController * controller = [[UINavigationController alloc] initWithRootViewController:notice];
        if (!usingLightTheme) {
            controller.navigationBar.translucent = NO;
        }
        controller.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
        if (@available(iOS 11.0, *)) {
            controller.navigationBar.prefersLargeTitles = YES;
        }
        UserOptions.currentOptions.contactNagDismissed = @YES;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

IMPL_SET_THEME_WORKAROUND

- (void) viewDidAppear:(BOOL)animated {
    [self.descriptionInput becomeFirstResponder];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+ (void) collectFeedbackOnController:(UIViewController *)controller finished:(void (^)(NSString *))finished {
    ContactSupportTableViewController * view = [controller.storyboard instantiateViewControllerWithIdentifier:@"ContactSupport"];
    view.feedbackFinished = finished;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:view];
    [controller presentViewController:navigationController animated:YES completion:nil];
}

- (void) textViewDidChange:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem.enabled = [self numberOfWords] >= 5;
}

- (void) cancel:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger) numberOfWords {
    return [self.descriptionInput.text componentsSeparatedByString:@" "].count;
}

- (void) next:(UIBarButtonItem *)sender {
    if ([self numberOfWords] < 5) {
        return;
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.feedbackFinished(self.descriptionInput.text);
        });
    }];
}

@end
