#import "ValueViewController.h"

@interface ValueViewController ()

@property (strong, nonatomic) NSString * value;
@property (strong, nonatomic) NSString * viewTitle;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ValueViewController

- (void) viewDidLoad {
    self.textView.text = self.value;
    self.title = self.viewTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                              target:self action:@selector(actionButton:)];

    if (usingLightTheme) {
        self.textView.backgroundColor = [UIColor whiteColor];
        self.textView.textColor = [UIColor blackColor];
    } else {
        self.textView.backgroundColor = [UIColor colorWithRed:0.106 green:0.157 blue:0.212 alpha:1.0];
        self.textView.textColor = [UIColor whiteColor];
    }

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadValue:(NSString *)value title:(NSString *)title {
    _value = value;
    _viewTitle = title;
}

- (void) actionButton:(id)sender {
    [uihelper presentActionSheetInViewController:self
                                  attachToTarget:[ActionTipTarget targetWithBarButtonItem:self.navigationItem.rightBarButtonItem]
                                           title:self.title
                                        subtitle:[lang key:@"{0} characters" args:@[format(@"%lu", (unsigned long)self.value.length)]]
                               cancelButtonTitle:l(@"Cancel")
                                           items:@[l(@"Copy"), l(@"Verify"), l(@"Share")]
                                       dismissed:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0: { // Copy
                [[UIPasteboard generalPasteboard] setString:self.value];
                break;
            } case 1: { // Verify
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:l(@"Verify Value")
                                                                                         message:l(@"Enter the value to verify")
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = l(@"Value");
                }];

                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:l(@"Cancel")
                                                                       style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:l(@"Verify")
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
                                                                     UITextField * inputField = alertController.textFields.firstObject;
                                                                     [self verifyValue:inputField.text];
                                                                 }];

                [alertController addAction:cancelAction];
                [alertController addAction:okAction];

                [self presentViewController:alertController animated:YES completion:nil];
                break;
            } case 2: { // Share
                UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                                initWithActivityItems:@[self.value]
                                                                applicationActivities:nil];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    activityController.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
                }
                [self presentViewController:activityController animated:YES completion:nil];
                break;
            }
        }
    }];
}

- (void) verifyValue:(NSString *)value {
    NSString * (^formatValue)(NSString *) = ^NSString *(NSString * unformattedValue) {
        return [[unformattedValue lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    };
    NSString * formattedCurrentValue = formatValue(self.value);
    NSString * formattedExpectedValue = formatValue(value);
    if ([formattedExpectedValue isEqualToString:formattedCurrentValue]) {
        [uihelper presentAlertInViewController:self title:l(@"Verified") body:l(@"Both values matched.") dismissButtonTitle:l(@"Dismiss") dismissed:nil];
    } else {
        [uihelper presentAlertInViewController:self title:l(@"Not Verified") body:l(@"Values do not match.") dismissButtonTitle:l(@"Dismiss") dismissed:nil];
    }
}
@end
