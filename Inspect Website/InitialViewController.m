#import "InitialViewController.h"
#import "SplitViewController.h"
#import "UIHelper.h"

#include <MobileCoreServices/MobileCoreServices.h>

@interface InitialViewController () <CKGetterDelegate>

@property (strong, nonatomic) CKGetter * infoGetter;

@end

@implementation InitialViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    [[AppState currentState] setAppearance];
    [AppState currentState].extensionContext = self.extensionContext;

    self.infoGetter = [CKGetter newGetter];
    self.infoGetter.delegate = self;

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
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });

    [self.infoGetter getInfoForURL:url];
}

- (void) unsupportedURL {
    [[UIHelper sharedInstance]
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

- (void) finishedGetter:(CKGetter *)getter {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        currentChain = getter.chain;
        currentServerInfo = getter.serverInfo;
        selectedCertificate = getter.chain.certificates[0];
        UIStoryboard * main = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UISplitViewController * split = [main instantiateViewControllerWithIdentifier:@"SplitView"];
        [self presentViewController:split animated:YES completion:nil];
    });
}

- (void) getter:(CKGetter *)getter gotCertificateChain:(CKCertificateChain *)chain {
    NSLog(@"Hi");
}

- (void) getter:(CKGetter *)getter gotServerInfo:(CKServerInfo * _Nonnull)serverInfo {
    NSLog(@"Hi");
}

- (void) getter:(CKGetter *)getter errorGettingServerInfo:(NSError *)error {
    NSLog(@"Hi");
}

- (void) getter:(CKGetter *)getter errorGettingCertificateChain:(NSError *)error {
    NSLog(@"Hi");
}

@end
