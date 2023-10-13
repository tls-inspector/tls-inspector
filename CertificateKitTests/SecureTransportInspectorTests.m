#import <XCTest/XCTest.h>
#import <CertificateKit/CertificateKit.h>
#import "CKInspectorTests.h"

@interface SecureTransportInspectorTests : XCTestCase

@end

@implementation SecureTransportInspectorTests

#define ENGINE_NAME CRYPTO_ENGINE_SECURE_TRANSPORT

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
    // Note: testBareTLSIPv4 are intentionally skipped as socket address logic is broken within XCode tests for CFStreams
    // and since SecureTransport is legacy I really can't be bothered to spend much effort on fixing it.
}

- (void) testBareTLSIPv6 {
    // Note: testBareTLSIPv6 are intentionally skipped as socket address logic is broken within XCode tests for CFStreams
    // and since SecureTransport is legacy I really can't be bothered to spend much effort on fixing it.
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
    // TODO: This test is flaky. "It works on my machine", but fails in GitHub actions. Priority is low, as SecureTransport is legacy
    // [CKInspectorTests testTooManyHTTPHeadersWithEngine:ENGINE_NAME];
}

- (void) testHTTPSRedirect {
    [CKInspectorTests testHTTPSRedirect:ENGINE_NAME];
}

- (void) testNaughtyHTTPSRedirect {
    [CKInspectorTests testNaughtyHTTPSRedirect:ENGINE_NAME];
}

@end
