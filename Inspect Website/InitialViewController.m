//
//  InitialViewController.m
//  Certificate Inspector
//
//  GPLv3 License
//  Copyright (c) 2016 Ian Spence
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

#import "InitialViewController.h"
#import "CertificateListTableViewController.h"
#import "UIHelper.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider * itemProvider = item.attachments.firstObject;
    if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
        [itemProvider loadItemForTypeIdentifier:@"public.url"
                                        options:nil
                              completionHandler:^(NSURL *url, NSError *error) {
                                  if ([url.scheme isEqualToString:@"https"]) {
                                      CertificateListTableViewController * certList = [[UIStoryboard
                                                                                        storyboardWithName:@"Main"
                                                                                        bundle:[NSBundle mainBundle]]
                                                                                       instantiateViewControllerWithIdentifier:@"Certificate List"];
                                      certList.host = url.absoluteString;
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self pushViewController:certList animated:NO];
                                      });
                                  } else {
                                      [[UIHelper sharedInstance]
                                       presentAlertInViewController:self
                                       title:lang(@"Unsupported Scheme")
                                       body:lang(@"Only HTTPS sites can be inspected")
                                       dismissButtonTitle:lang(@"Dismiss")
                                       dismissed:^(NSInteger buttonIndex) {
                                           [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
                                       }];
                                  }
                              }];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
