#import "ContactSupportTableViewController.h"

@interface ContactSupportTableViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *descriptionInput;

@property (nonatomic) void (^feedbackFinished)(NSString *);

@end

@implementation ContactSupportTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    [uihelper applyStylesToNavigationBar:self.navigationController.navigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(next:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.descriptionInput.textColor = themeTextColor;
    self.descriptionInput.keyboardAppearance = usingLightTheme ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark;
}

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
