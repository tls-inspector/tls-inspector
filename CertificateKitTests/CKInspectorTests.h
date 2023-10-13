#import <Foundation/Foundation.h>
@import CertificateKit;

NS_ASSUME_NONNULL_BEGIN

@interface CKInspectorTests : NSObject

+ (void) testBasicHTTPSWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testBareTLSWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testBareTLSIPv4WithEngine:(CRYPTO_ENGINE)engine;
+ (void) testBareTLSIPv6WithEngine:(CRYPTO_ENGINE)engine;
+ (void) testTooManyCertsWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testNaughtyHTTPWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testFuzzHTTPWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testFuzzTLSWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testBigHTTPHeaderWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testRevokedCRLWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testRevokedOCSPWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testExpiredLeafWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testExpiredIntWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testTooManyHTTPHeadersWithEngine:(CRYPTO_ENGINE)engine;
+ (void) testHTTPSRedirect:(CRYPTO_ENGINE)engine;
+ (void) testNaughtyHTTPSRedirect:(CRYPTO_ENGINE)engine;

@end

NS_ASSUME_NONNULL_END
