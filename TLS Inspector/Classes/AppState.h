#import <Foundation/Foundation.h>
#import "SplitViewController.h"
#import "GetterTableViewController.h"
#import <CertificateKit/CertificateKit.h>

@interface AppState : NSObject

+ (AppState * _Nonnull) currentState;
- (id _Nonnull) init;

@property (strong, nonatomic, nullable) SplitViewController * splitViewController;
@property (strong, nonatomic, nullable) GetterTableViewController * getterViewController;
@property (strong, nonatomic, nullable) CKCertificateChain * certificateChain;
@property (strong, nonatomic, nullable) CKCertificate * selectedCertificate;
@property (nonatomic) BOOL lightTheme;

#ifdef EXTENSION
@property (nullable, nonatomic, strong) NSExtensionContext * extensionContext;
#endif

- (void) setAppearance;

@end
