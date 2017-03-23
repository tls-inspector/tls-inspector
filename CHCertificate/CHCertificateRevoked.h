#import <Foundation/Foundation.h>

@interface CHCertificateRevoked : NSObject

typedef NS_ENUM(NSInteger, CHCertificateRevokedReason) {
    CHCertificateRevokedReasonUnspecified          = 0,
    CHCertificateRevokedReasonKeyCompromise        = 1,
    CHCertificateRevokedReasonCACompromise         = 2,
    CHCertificateRevokedReasonAffiliationChanged   = 3,
    CHCertificateRevokedReasonSuperseded           = 4,
    CHCertificateRevokedReasonCessationOfOperation = 5,
    CHCertificateRevokedReasonCertificateHold      = 6,
    CHCertificateRevokedReasonRemoveFromCRL        = 8,
    CHCertificateRevokedReasonPrivilegeWithdrawn   = 9,
    CHCertificateRevokedReasonAACompromise         = 10
};

@property (nonatomic) BOOL isRevoked;
@property (nonatomic) CHCertificateRevokedReason reason;
@property (strong, nonatomic, readonly, nullable) NSDate * date;

@end
