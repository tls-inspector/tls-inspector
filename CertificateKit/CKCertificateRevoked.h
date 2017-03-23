#import <Foundation/Foundation.h>
#import "CKCertificate.h"

@class CKCertificate;

@interface CKCertificateRevoked : NSObject

typedef NS_ENUM(NSInteger, CKCertificateRevokedReason) {
    CKCertificateRevokedReasonUnspecified          = 0,
    CKCertificateRevokedReasonKeyCompromise        = 1,
    CKCertificateRevokedReasonCACompromise         = 2,
    CKCertificateRevokedReasonAffiliationChanged   = 3,
    CKCertificateRevokedReasonSuperseded           = 4,
    CKCertificateRevokedReasonCessationOfOperation = 5,
    CKCertificateRevokedReasonCertificateHold      = 6,
    CKCertificateRevokedReasonRemoveFromCRL        = 8,
    CKCertificateRevokedReasonPrivilegeWithdrawn   = 9,
    CKCertificateRevokedReasonAACompromise         = 10
};

@property (nonatomic) BOOL isRevoked;
@property (nonatomic) CKCertificateRevokedReason reason;
@property (strong, nonatomic, readonly, nullable) NSDate * date;

- (void) isCertificateRevoked:(CKCertificate * _Nonnull)cert
                       rootCA:(CKCertificate * _Nonnull)rootCA
                     finished:(void (^ _Nonnull)(NSError * _Nullable error))finished;

@end
