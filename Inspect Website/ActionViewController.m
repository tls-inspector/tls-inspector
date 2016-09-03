#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CHCertificate.h"
#import "UIHelper.h"

@interface ActionViewController () {
    CHCertificate * selectedCertificate;
    BOOL isTrusted;
}

@property (strong, nonatomic) NSString * url;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerViewLabel;
@property (strong, nonatomic) NSArray<CHCertificate *> * certificates;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerViewLabel.text = @"Loading...";
    
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider * itemProvider = item.attachments.firstObject;
    if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
        [itemProvider loadItemForTypeIdentifier:@"public.url"
                                        options:nil
                              completionHandler:^(NSURL *url, NSError *error) {
                                  NSLog(@"%@", url.absoluteString);
                                  self.url = url.absoluteString;
                                  CHCertificate * cert = [CHCertificate new];
                                  [cert fromURL:self.url finished:^(NSError *error, NSArray<CHCertificate *> *certificates, BOOL trustedChain) {
                                      if (error) {
                                          [[UIHelper sharedInstance]
                                           presentAlertInViewController:self
                                           title:@"Could not get certificates"
                                           body:error.localizedDescription
                                           dismissButtonTitle:@"Dismiss"
                                           dismissed:^(NSInteger buttonIndex) {
                                               [self done];
                                           }];
                                      } else {
                                          self.certificates = certificates;
                                          isTrusted = trustedChain;
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (trustedChain) {
                                                  self.headerViewLabel.text = @"Trusted Chain";
                                                  self.headerView.backgroundColor = [UIColor colorWithRed:0.298 green:0.686 blue:0.314 alpha:1];
                                              } else {
                                                  self.headerViewLabel.text = @"Untrusted Chain";
                                                  self.headerView.backgroundColor = [UIColor colorWithRed:0.957 green:0.263 blue:0.212 alpha:1];
                                              }
                                              self.headerViewLabel.textColor = [UIColor whiteColor];
                                              [self.tableView reloadData];
                                          });
                                      }
                                  }];
                              }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.certificates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHCertificate * cert = [self.certificates objectAtIndex:indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
    cell.textLabel.text = cert.summary;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedCertificate = [self.certificates objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ViewCert" sender:nil];
}

- (IBAction)headerButton:(id)sender {
    NSString * title = isTrusted ? lang(@"Trusted Chain") : lang(@"Untrusted Chain");
    NSString * body = isTrusted ? lang(@"trusted_chain_description") : lang(@"untrusted_chain_description");
    [[UIHelper sharedInstance]
     presentAlertInViewController:self
     title:title
     body:body
     dismissButtonTitle:lang(@"Dismiss")
     dismissed:nil];
}

@end
