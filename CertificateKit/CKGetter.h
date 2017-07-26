#import <Foundation/Foundation.h>
#import "CKCertificateChain.h"
#import "CKServerInfo.h"

@interface CKGetter : NSObject

+ (CKGetter * _Nonnull) newGetter;
- (void) getInfoForURL:(NSURL * _Nonnull)URL;

@property (weak, nonatomic, nullable) id delegate;

@property (strong, nonatomic, nullable) CKCertificateChain * chain;
@property (strong, nonatomic, nullable) CKServerInfo * serverInfo;

@end

@protocol CKGetterDelegate

- (void) finishedGetter:(CKGetter * _Nonnull)getter;
- (void) getter:(CKGetter * _Nonnull)getter gotCertificateChain:(CKCertificateChain * _Nonnull)chain;
- (void) getter:(CKGetter * _Nonnull)getter gotServerInfo:(CKServerInfo * _Nonnull)serverInfo;
- (void) getter:(CKGetter * _Nonnull)getter errorGettingCertificateChain:(NSError * _Nonnull)error;
- (void) getter:(CKGetter * _Nonnull)getter errorGettingServerInfo:(NSError * _Nonnull)error;

@end
