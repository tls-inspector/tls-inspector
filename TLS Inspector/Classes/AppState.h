#import <Foundation/Foundation.h>
#import "CHCertificateChain.h"
#import "SplitViewController.h"

@interface AppState : NSObject

+ (AppState * _Nonnull) currentState;
- (id _Nonnull) init;

@property (strong, nonatomic, nullable) SplitViewController * splitViewController;
@property (strong, nonatomic, nullable) CHCertificateChain * certificateChain;
@property (strong, nonatomic, nullable) CHCertificate * selectedCertificate;

@end
