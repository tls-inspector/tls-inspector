#import "InitialViewController.h"
#import "SplitViewController.h"
#import "UIHelper.h"

#include <MobileCoreServices/MobileCoreServices.h>

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    [[AppState currentState] setAppearance];
    [AppState currentState].extensionContext = self.extensionContext;

    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            
            NSString * urlString = [item.attributedContentText string];
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePlainText]) {
                // Long-press on URL in Safari or share from other app
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePlainText options:nil completionHandler:^(NSString *text, NSError *error) {
                    [self parseURLString:text];
                }];
                return;
            } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                // Share page from within Safari
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    if (!error && [url.scheme isEqualToString:@"https"]) {
                        [self loadURL:url];
                    } else {
                        [self unsupportedURL];
                    }
                }];
                return;
            } else if (urlString)  {
                // Share page from third-party browsers (Chrome, Brave 🦁)
                [self parseURLString:urlString];
                return;
            }
        }
    }

    [self closeExtension];
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
