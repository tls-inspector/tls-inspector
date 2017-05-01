#import <Foundation/Foundation.h>
#import "CKCertificate.h"

@class CKCertificate;

/**
 X.509 Certificate public key information
 */
@interface CKCertificatePublicKey : NSObject

/**
 The algroithm of the public key, as a string.
 */
@property (strong, nonatomic, nonnull, readonly) NSString * algroithm;
/**
 The length of the public key in bits.
 */
@property (nonatomic, readonly) int bitLength;

/**
 Populate a public key info model with information from the given CKCertificate.

 @param cert The CKCertificate to populate the model from.
 @return A populated model or nil on error.
 */
+ (CKCertificatePublicKey * _Nullable) infoFromCertificate:(CKCertificate * _Nonnull)cert;

@end
