#import "InitialViewController.h"
#import "CertificateListTableViewController.h"
#import "UIHelper.h"

#include <MobileCoreServices/MobileCoreServices.h>

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            
            NSString * urlString = [item.attributedContentText string];
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    if (!error && [url.scheme isEqualToString:@"https"]) {
                        [self loadURL:url.absoluteString];
                    } else {
                        [self unsupportedURL];
                    }
                }];
            } else if (urlString)  {
                if ([urlString hasPrefix:@"https://"]){
                    [self loadURL:[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                } else {
                    [self unsupportedURL];
                }
            }
        }
    }
}

- (void) loadURL:(NSString *)url {
    CertificateListTableViewController * certList = [[UIStoryboard
                                                      storyboardWithName:@"Main"
                                                      bundle:[NSBundle mainBundle]]
                                                     instantiateViewControllerWithIdentifier:@"Certificate List"];
    certList.host = url;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushViewController:certList animated:NO];
    });
}

- (void) unsupportedURL {
    [[UIHelper sharedInstance]
     presentAlertInViewController:self
     title:l(@"Unsupported Scheme")
     body:l(@"Only HTTPS sites can be inspected")
     dismissButtonTitle:l(@"Dismiss")
     dismissed:^(NSInteger buttonIndex) {
         [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
     }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
