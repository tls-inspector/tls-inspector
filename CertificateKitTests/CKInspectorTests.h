#import <Foundation/Foundation.h>
@import CertificateKit;

NS_ASSUME_NONNULL_BEGIN

@interface CKInspectorTests : NSObject

+ (void) testBasicHTTPSWithEngine:(CKNetworkEngine)engine;
+ (void) testBareTLSWithEngine:(CKNetworkEngine)engine;
+ (void) testBareTLSIPv4WithEngine:(CKNetworkEngine)engine;
+ (void) testBareTLSIPv6WithEngine:(CKNetworkEngine)engine;
+ (void) testTooManyCertsWithEngine:(CKNetworkEngine)engine;
+ (void) testNaughtyHTTPWithEngine:(CKNetworkEngine)engine;
+ (void) testFuzzHTTPWithEngine:(CKNetworkEngine)engine;
+ (void) testFuzzTLSWithEngine:(CKNetworkEngine)engine;
+ (void) testBigHTTPHeaderWithEngine:(CKNetworkEngine)engine;
+ (void) testRevokedCRLWithEngine:(CKNetworkEngine)engine;
+ (void) testRevokedOCSPWithEngine:(CKNetworkEngine)engine;
+ (void) testExpiredLeafWithEngine:(CKNetworkEngine)engine;
+ (void) testExpiredIntWithEngine:(CKNetworkEngine)engine;
+ (void) testTooManyHTTPHeadersWithEngine:(CKNetworkEngine)engine;
+ (void) testHTTPSRedirect:(CKNetworkEngine)engine;
+ (void) testNaughtyHTTPSRedirect:(CKNetworkEngine)engine;

@end

NS_ASSUME_NONNULL_END
