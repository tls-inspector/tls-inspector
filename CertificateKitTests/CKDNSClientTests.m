#import <XCTest/XCTest.h>
#import <CertificateKit/CertificateKit.h>
#import "CertificateKitTests.h"
#import "CKInspectorTests.h"

@interface CKDNSClientTests : XCTestCase

@end

@implementation CKDNSClientTests

#define DOH_SERVER @"https://localhost:8412/dns-query"
#define TEST_TIMEOUT 10 // Seconds

- (void) setUp {
    [super setUp];
}

- (void) tearDown {
    [super tearDown];
}

- (void) testSingleAddressA {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"single.address.a.example.com" ofType:CKDNSRecordTypeA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        NSError * addressError;
        NSArray<NSString *> * addresses = [result addressesForName:@"single.address.a.example.com" error:&addressError];
        XCTAssertNil(addressError);
        XCTAssertNotNil(addresses);
        XCTAssertEqual(addresses.count, 1);
        NSString * address = addresses[0];
        XCTStringEqual(address, @"192.0.2.1");
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testMultipleAddressA {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"multiple.address.a.example.com" ofType:CKDNSRecordTypeA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        NSError * addressError;
        NSArray<NSString *> * addresses = [result addressesForName:@"multiple.address.a.example.com" error:&addressError];
        XCTAssertNil(addressError);
        XCTAssertNotNil(addresses);
        XCTAssertEqual(addresses.count, 3);
        NSString * address1 = addresses[0];
        NSString * address2 = addresses[1];
        NSString * address3 = addresses[2];
        XCTStringEqual(address1, @"192.0.2.1");
        XCTStringEqual(address2, @"192.0.2.2");
        XCTStringEqual(address3, @"192.0.2.3");
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testCNAMEA {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"cname.a.example.com" ofType:CKDNSRecordTypeA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        NSError * addressError;
        NSArray<NSString *> * addresses = [result addressesForName:@"cname.a.example.com" error:&addressError];
        XCTAssertNil(addressError);
        XCTAssertNotNil(addresses);
        XCTAssertEqual(addresses.count, 1);
        NSString * address = addresses[0];
        XCTStringEqual(address, @"192.0.2.1");
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testSingleAddressAAAA {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"single.address.aaaa.example.com" ofType:CKDNSRecordTypeAAAA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        NSError * addressError;
        NSArray<NSString *> * addresses = [result addressesForName:@"single.address.aaaa.example.com" error:&addressError];
        XCTAssertNil(addressError);
        XCTAssertNotNil(addresses);
        XCTAssertEqual(addresses.count, 1);
        NSString * address = addresses[0];
        XCTStringEqual(address, @"2001:db8::1");
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testMultipleAddressAAAA {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"multiple.address.aaaa.example.com" ofType:CKDNSRecordTypeAAAA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        NSError * addressError;
        NSArray<NSString *> * addresses = [result addressesForName:@"multiple.address.aaaa.example.com" error:&addressError];
        XCTAssertNil(addressError);
        XCTAssertNotNil(addresses);
        XCTAssertEqual(addresses.count, 3);
        NSString * address1 = addresses[0];
        NSString * address2 = addresses[1];
        NSString * address3 = addresses[2];
        XCTStringEqual(address1, @"2001:db8::1");
        XCTStringEqual(address2, @"2001:db8::2");
        XCTStringEqual(address3, @"2001:db8::3");
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testCNAMEAAAA {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"cname.aaaa.example.com" ofType:CKDNSRecordTypeAAAA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        NSError * addressError;
        NSArray<NSString *> * addresses = [result addressesForName:@"cname.aaaa.example.com" error:&addressError];
        XCTAssertNil(addressError);
        XCTAssertNotNil(addresses);
        XCTAssertEqual(addresses.count, 1);
        NSString * address = addresses[0];
        XCTStringEqual(address, @"2001:db8::1");
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testRecursiveCNAME {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"recursive.cname.example.com" ofType:CKDNSRecordTypeA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        NSError * addressError;
        NSArray<NSString *> * addresses = [result addressesForName:@"recursive.cname.example.com" error:&addressError];
        XCTAssertNotNil(addressError);
        XCTAssertNil(addresses);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testInfiniteLoopCompression {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"infinite.loop.compression.example.com" ofType:CKDNSRecordTypeA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(result);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testIncorrectID {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"incorrect.id.example.com" ofType:CKDNSRecordTypeA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(result);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testNXDOMAIN {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"unknown.domain.example.com" ofType:CKDNSRecordTypeA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.responseCode, CKDNSResponseCodeNXDOMAIN);
        XCTAssertEqual(result.resources.count, 0);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testWrongRType {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"wrong.type.example.com" ofType:CKDNSRecordTypeA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.resources.count, 0);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testBadDataLength {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"bad.length.example.com" ofType:CKDNSRecordTypeA onServer:DOH_SERVER completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(result);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testBadContentType {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"example.com" ofType:CKDNSRecordTypeA onServer:@"https://localhost:8412/bad-content-type" completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(result);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testOversizedReply {
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [CKDNSClient.sharedClient resolve:@"example.com" ofType:CKDNSRecordTypeA onServer:@"https://localhost:8412/oversize-reply" completed:^(CKDNSResult * result, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(result);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

@end
