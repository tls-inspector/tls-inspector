#import <XCTest/XCTest.h>
#import <CertificateKit/CertificateKit.h>

@interface CertificateKitTests : XCTestCase

@property (strong, nonatomic) CKCertificateChain * chainGetter;

@end

@implementation CertificateKitTests

- (void) setUp {
    [super setUp];
}

- (void) tearDown {
    [super tearDown];
}

# pragma mark - Getter Parsing

/// Test that the getter can parse a simple domain name
- (void) testGetterParseDomainName {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"www.google.com";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"www.google.com"]);
    XCTAssertTrue(getterParameters.port == 443);
}

/// Test that the getter can parse a domain name with a port
- (void) testGetterParseDomainNameWithPort {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"www.google.com:7443";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"www.google.com"]);
    XCTAssertTrue(getterParameters.port == 7443);
}

/// Test that the getter can parse an IPv4 address
- (void) testGetterParseIPv4Address {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"1.1.1.1";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"1.1.1.1"]);
    XCTAssertTrue(getterParameters.port == 443);
}

/// Test that the getter can parse an IPv4 address with a port
- (void) testGetterParseIPv4AddressWithPort {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"1.1.1.1:7443";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"1.1.1.1"]);
    XCTAssertTrue(getterParameters.port == 7443);
}

/// Test that the getter can parse an IPv6 address
- (void) testGetterParseIPv6Address {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"2606:4700:4700::1111";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"2606:4700:4700::1111"]);
    XCTAssertTrue(getterParameters.port == 443);
}
/// Test that the getter can parse an IPv6 address with a port
- (void) testGetterParseIPv6AddressWithPort {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"[2606:4700:4700::1111]:7443";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"2606:4700:4700::1111"]);
    XCTAssertTrue(getterParameters.port == 7443);
}

/// Test that the getter honors a domain name with a specified port
- (void) testGetterWithSpecifiedPort {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"localhost";
    inspectParameters.port = 7443;
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"localhost"]);
    XCTAssertTrue(getterParameters.port == 7443);
}

/// Test that the getter chooses the specific port even if there is a port specified in the host address
- (void) testGetterWithSpecifiedPortAndHostPort {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"localhost:443";
    inspectParameters.port = 7443;
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"localhost"]);
    XCTAssertTrue(getterParameters.port == 7443);
}

- (void) testGetterParseURLNameWithPort {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"https://www.google.com:7443/something/else.html?query=param#value";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"www.google.com"]);
    XCTAssertTrue(getterParameters.port == 7443);
}

@end
