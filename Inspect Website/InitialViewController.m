#import "InitialViewController.h"
#import "SplitViewController.h"
#import "UIHelper.h"
#import "NSAtomicNumber.h"

#include <MobileCoreServices/MobileCoreServices.h>

@interface InitialViewController ()

@property (strong, nonatomic) NSAtomicNumber * latch;
@property (strong, nonatomic) NSMutableArray * values;

@end

@implementation InitialViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    [[AppState currentState] setAppearance];
    [AppState currentState].extensionContext = self.extensionContext;

    self.latch = [NSAtomicNumber numberWithInitialValue:0];
    self.values = [NSMutableArray new];

    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            NSString * urlString = [item.attributedContentText string];
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [self.latch incrementAndGet];
                // Share page from within Safari
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    [self.latch decrementAndGet];
                    if (url) {
                        [self.values addObject:url];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{ [self checkValues]; });
                }];
            } else if (urlString)  {
                // Share page from third-party browsers (Chrome, Brave 🦁)
                [self.values addObject:urlString];
                dispatch_async(dispatch_get_main_queue(), ^{ [self checkValues]; });
            } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePlainText]) {
                [self.latch incrementAndGet];
                // Long-press on URL in Safari or share from other app
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePlainText options:nil completionHandler:^(NSString *text, NSError *error) {
                    [self.latch decrementAndGet];
                    NSURL * url = [NSURL URLWithString:text];
                    if (url) {
                        [self.values addObject:text];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{ [self checkValues]; });
                }];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{ [self checkValues]; });
}

- (void) checkValues {
    if ([self.latch getValue] <= 0) {
        if (self.values.count == 0) {
            [self closeExtension];
            return;
        }

        BOOL validURLFound = NO;

        for (id value in self.values) {
            NSURL * url;
            if ([value isKindOfClass:[NSURL class]]) {
                url = (NSURL *)value;
            } else if ([value isKindOfClass:[NSString class]]) {
                url = [NSURL URLWithString:value];
            }

            if (url) {
                if ([url.scheme isEqualToString:@"https"]) {
                    validURLFound = YES;
                    [self loadURL:url];
                }
            }
        }

        if (!validURLFound) {
            [self unsupportedURL];
        }
    }
}

- (void) parseURLString:(NSString *)urlString {
    if ([urlString hasPrefix:@"https://"]){
        [self loadURL:[NSURL URLWithString:[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
    } else {
        [self unsupportedURL];
    }
    return;
}

- (void) loadURL:(NSURL *)url {
    UIStoryboard * main = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    GetterTableViewController * getter = [main instantiateViewControllerWithIdentifier:@"Getter"];
    [getter presentGetter:self ForUrl:url finished:nil];
}

- (void) unsupportedURL {
    [uihelper
     presentAlertInViewController:self
     title:l(@"Unsupported Scheme")
     body:l(@"Only HTTPS sites can be inspected")
     dismissButtonTitle:l(@"Dismiss")
     dismissed:^(NSInteger buttonIndex) {
         [self closeExtension];
     }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) closeExtension {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

- (IBAction)closeButton:(id)sender {
    [self closeExtension];
}

@end
