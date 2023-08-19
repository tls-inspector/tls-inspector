#import <XCTest/XCTest.h>
#import <CertificateKit/CertificateKit.h>
#import "CertificateKitTests.h"

@interface OpenSSLInspectorTests : XCTestCase {
    CRYPTO_ENGINE engine;
}

@end

@implementation OpenSSLInspectorTests

- (void) setUp {
    engine = CRYPTO_ENGINE_OPENSSL;
    [super setUp];
}

- (void) tearDown {
    [super tearDown];
}

- (void) testBasicHTTPS {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8401"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testBasicHTTPS", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer != nil);
        XCTAssertEqual(response.httpServer.statusCode, 200);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertTrue(certificates.count >= 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BasicHTTPS)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BasicHTTPS)");
        if (certificates.count == 3) {
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testBareTLS {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8402"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testBareTLS", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertTrue(certificates.count >= 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BareTLS)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BareTLS)");
        if (certificates.count == 3) {
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testBareTLSIPv4 {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"127.0.0.1:8402"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testBareTLS", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertTrue(certificates.count >= 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BareTLS)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BareTLS)");
        XCTStringEqual(response.certificateChain.remoteAddress.full, @"127.0.0.1");
        if (certificates.count == 3) {
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testBareTLSIPv6 {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"[0:0:0:0:0:0:0:1]:8402"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testBareTLS", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertTrue(certificates.count >= 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BareTLS)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BareTLS)");
        XCTStringEqual(response.certificateChain.remoteAddress.full, @"0000:0000:0000:0000:0000:0000:0000:0001");
        if (certificates.count == 3) {
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testTooManyCerts {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8403"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testTooManyCerts", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        XCTStringEqual(error.localizedDescription, @"Too many certificates from server");
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testNaughtyHTTP {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8404"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testNaughtyHTTP", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertTrue(certificates.count >= 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (NaughtyHTTP)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (NaughtyHTTP)");
        if (certificates.count == 3) {
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testFuzzHTTP {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8405"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testFuzzHTTP", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertTrue(certificates.count >= 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (FuzzHTTP)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (FuzzHTTP)");
        if (certificates.count == 3) {
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testFuzzTLS {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8406"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testFuzzTLS", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testBigHTTPHeader {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8407"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testBigHTTPHeader", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertTrue(certificates.count >= 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BigHTTPHeader)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BigHTTPHeader)");
        if (certificates.count == 3) {
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testRevokedCRL {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8408"];
    parameters.cryptoEngine = engine;
    parameters.checkCRL = true;
    parameters.checkOCSP = false;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testRevokedCRL", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertTrue(certificates.count >= 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (RevokedCert)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (RevokedCert)");
        CKRevoked * status = certificates[0].revoked;
        XCTAssertNotNil(status);
        XCTAssertTrue(status.isRevoked);
        XCTAssertEqual(status.reason, CKRevokedReasonKeyCompromise);
        if (certificates.count == 3) {
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

- (void) testRevokedOCSP {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8408"];
    parameters.cryptoEngine = engine;
    parameters.checkCRL = false;
    parameters.checkOCSP = true;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testRevokedCRL", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertTrue(certificates.count >= 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (RevokedCert)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (RevokedCert)");
        CKRevoked * status = certificates[0].revoked;
        XCTAssertNotNil(status);
        XCTAssertTrue(status.isRevoked);
        XCTAssertEqual(status.reason, CKRevokedReasonKeyCompromise);
        if (certificates.count == 3) {
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

@end
