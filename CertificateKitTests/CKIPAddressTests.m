#import <XCTest/XCTest.h>
#import "CertificateKitTests.h"
#import "CKInspectorTests.h"
@import CertificateKit;

@interface CKIPAddressTests : XCTestCase

@end

@implementation CKIPAddressTests

- (void) setUp {
    [super setUp];
}

- (void) tearDown {
    [super tearDown];
}

- (void) testIPv4 {
    CKIPAddress * normalIPv4 = [CKIPAddress fromString:@"127.0.0.1"];
    CKIPAddress * badIPv4 = [CKIPAddress fromString:@"256.0.0.1"];

    XCTAssertNotNil(normalIPv4, @"Normal IPv4 address should not be nil");
    XCTAssertTrue(normalIPv4.version == CKIPVersionIPv4, @"Normal IPv4 address should be version 4");
    XCTStringEqual(normalIPv4.full, @"127.0.0.1");
    XCTAssertNil(badIPv4, @"Invalid IPv4 address should be nil");
}

- (void) testIPv6 {
    CKIPAddress * normalIPv6 = [CKIPAddress fromString:@"0000:0000:0000:0000:0000:0000:0000:0001"];
    CKIPAddress * shortIPv6 = [CKIPAddress fromString:@"::1"];
    CKIPAddress * badIPv6 = [CKIPAddress fromString:@"DEFG:0000:0000:0000:0000:0000:0000:0001"];

    XCTAssertNotNil(normalIPv6, @"Normal IPv6 address should not be nil");
    XCTAssertTrue(normalIPv6.version == CKIPVersionIPv6, @"Normal IPv6 address should be version 6");
    XCTStringEqual(normalIPv6.full, @"0000:0000:0000:0000:0000:0000:0000:0001");
    XCTAssertNotNil(shortIPv6, @"Short IPv6 address should not be nil");
    XCTAssertTrue(shortIPv6.version == CKIPVersionIPv6, @"Short IPv6 address should be version 6");
    XCTStringEqual(shortIPv6.full, @"0000:0000:0000:0000:0000:0000:0000:0001");
    XCTStringEqual(shortIPv6.address, @"::1");
    XCTAssertNil(badIPv6, @"Invalid IPv6 address should be nil");
}

@end
