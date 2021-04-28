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

- (void) testGetterParseDomainName {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"www.google.com";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"www.google.com"]);
    XCTAssertTrue(getterParameters.port == 443);
}

- (void) testGetterParseDomainNameWithPort {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"www.google.com:7443";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"www.google.com"]);
    XCTAssertTrue(getterParameters.port == 7443);
}

- (void) testGetterParseIPv4Address {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"1.1.1.1";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"1.1.1.1"]);
    XCTAssertTrue(getterParameters.port == 443);
}

- (void) testGetterParseIPv4AddressWithPort {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"1.1.1.1:7443";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"1.1.1.1"]);
    XCTAssertTrue(getterParameters.port == 7443);
}

- (void) testGetterParseIPv6Address {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"2606:4700:4700::1111";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"2606:4700:4700::1111"]);
    XCTAssertTrue(getterParameters.port == 443);
}

- (void) testGetterParseIPv6AddressWithPort {
    CKInspectParameters * inspectParameters = [CKInspectParameters new];
    inspectParameters.hostAddress = @"[2606:4700:4700::1111]:7443";
    CKGetterParameters * getterParameters = [CKGetterParameters fromInspectParameters:inspectParameters];
    XCTAssertTrue([getterParameters.hostAddress isEqualToString:@"2606:4700:4700::1111"]);
    XCTAssertTrue(getterParameters.port == 7443);
}

@end
