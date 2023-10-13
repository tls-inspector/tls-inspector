#import <XCTest/XCTest.h>
#import <CertificateKit/CertificateKit.h>
#import "CKInspectorTests.h"

@interface NetworkFrameworkInspectorTests : XCTestCase

@end

@implementation NetworkFrameworkInspectorTests

#define ENGINE_NAME CRYPTO_ENGINE_NETWORK_FRAMEWORK

- (void) setUp {
    [super setUp];
}

- (void) tearDown {
    [super tearDown];
}

- (void) testBasicHTTPS {
    [CKInspectorTests testBasicHTTPSWithEngine:ENGINE_NAME];
}

- (void) testBareTLS {
    [CKInspectorTests testBareTLSWithEngine:ENGINE_NAME];
}

- (void) testBareTLSIPv4 {
    [CKInspectorTests testBareTLSIPv4WithEngine:ENGINE_NAME];
}

- (void) testBareTLSIPv6 {
    [CKInspectorTests testBareTLSIPv6WithEngine:ENGINE_NAME];
}

- (void) testTooManyCerts {
    [CKInspectorTests testTooManyCertsWithEngine:ENGINE_NAME];
}

- (void) testNaughtyHTTP {
    [CKInspectorTests testNaughtyHTTPWithEngine:ENGINE_NAME];
}

- (void) testFuzzHTTP {
    [CKInspectorTests testFuzzHTTPWithEngine:ENGINE_NAME];
}

- (void) testFuzzTLS {
    [CKInspectorTests testFuzzTLSWithEngine:ENGINE_NAME];
}

- (void) testBigHTTPHeader {
    [CKInspectorTests testBigHTTPHeaderWithEngine:ENGINE_NAME];
}

- (void) testRevokedCRL {
    [CKInspectorTests testRevokedCRLWithEngine:ENGINE_NAME];
}

- (void) testRevokedOCSP {
    [CKInspectorTests testRevokedOCSPWithEngine:ENGINE_NAME];
}

- (void) testExpiredLeaf {
    [CKInspectorTests testExpiredLeafWithEngine:ENGINE_NAME];
}

- (void) testExpiredInt {
    [CKInspectorTests testExpiredIntWithEngine:ENGINE_NAME];
}

- (void) testTooManyHTTPHeaders {
    [CKInspectorTests testTooManyHTTPHeadersWithEngine:ENGINE_NAME];
}

- (void) testHTTPSRedirect {
    [CKInspectorTests testHTTPSRedirect:ENGINE_NAME];
}

- (void) testNaughtyHTTPSRedirect {
    [CKInspectorTests testNaughtyHTTPSRedirect:ENGINE_NAME];
}

@end
