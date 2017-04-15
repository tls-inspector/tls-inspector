#import <Foundation/Foundation.h>
#import "SplitViewController.h"
@import CertificateKit;

@interface AppState : NSObject

+ (AppState * _Nonnull) currentState;
- (id _Nonnull) init;

@property (strong, nonatomic, nullable) SplitViewController * splitViewController;
@property (strong, nonatomic, nullable) CKCertificateChain * certificateChain;
@property (strong, nonatomic, nullable) CKCertificate * selectedCertificate;

#ifdef EXTENSION
@property (nullable, nonatomic, strong) NSExtensionContext * extensionContext;
#endif

- (void) setAppearance;

@end
