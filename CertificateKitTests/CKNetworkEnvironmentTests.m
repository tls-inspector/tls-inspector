#import <XCTest/XCTest.h>
#import "CertificateKitTests.h"
#import "CKInspectorTests.h"
@import CertificateKit;

@interface CKNetworkEnvironmentTests : XCTestCase

@end

@implementation CKNetworkEnvironmentTests

#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    [super setUp];
}

- (void) tearDown {
    [super tearDown];
}

- (void) testGetIPVersion {
    NSError * error;
    NSString * address;
    CKIPVersion version = [CKNetworkEnvironment getPreferredIPVersionOfHost:@"example.com" address:&address error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(version == CKIPVersionIPv4 || version == CKIPVersionIPv6);
}

@end
