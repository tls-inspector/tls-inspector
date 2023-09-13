#import <XCTest/XCTest.h>
#import "CertificateKitTests.h"
#import "CKInspectorTests.h"

@implementation CKInspectorTests

#define TEST_TIMEOUT 10 // Seconds

+ (void) testBasicHTTPSWithEngine:(CRYPTO_ENGINE)engine {
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
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BasicHTTPS)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BasicHTTPS)");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        CKHTTPServerInfo * serverInfo = response.httpServer;
        XCTAssertNotNil(serverInfo);
        for (NSString * headerKey in serverInfo.securityHeaders.allKeys) {
            XCTAssertTrue(serverInfo.securityHeaders[headerKey].boolValue);
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testBareTLSWithEngine:(CRYPTO_ENGINE)engine {
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
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BareTLS)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BareTLS)");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testBareTLSIPv4WithEngine:(CRYPTO_ENGINE)engine {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"127.0.0.1:8402"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testBareTLSIPv4", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BareTLS)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BareTLS)");
        XCTStringEqual(response.certificateChain.remoteAddress.full, @"127.0.0.1");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testBareTLSIPv6WithEngine:(CRYPTO_ENGINE)engine {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"[0:0:0:0:0:0:0:1]:8402"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testBareTLSIPv6", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BareTLS)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BareTLS)");
        XCTStringEqual(response.certificateChain.remoteAddress.full, @"0000:0000:0000:0000:0000:0000:0000:0001");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testTooManyCertsWithEngine:(CRYPTO_ENGINE)engine {
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
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testNaughtyHTTPWithEngine:(CRYPTO_ENGINE)engine {
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
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (NaughtyHTTP)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (NaughtyHTTP)");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testFuzzHTTPWithEngine:(CRYPTO_ENGINE)engine {
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
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (FuzzHTTP)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (FuzzHTTP)");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testFuzzTLSWithEngine:(CRYPTO_ENGINE)engine {
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
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testBigHTTPHeaderWithEngine:(CRYPTO_ENGINE)engine {
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
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BigHTTPHeader)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BigHTTPHeader)");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testRevokedCRLWithEngine:(CRYPTO_ENGINE)engine {
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
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (RevokedCert)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (RevokedCert)");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        CKRevoked * status = certificates[0].revoked;
        XCTAssertNotNil(status);
        XCTAssertTrue(status.isRevoked);
        XCTAssertEqual(status.reason, CKRevokedReasonKeyCompromise);
        XCTAssertEqual(response.certificateChain.trustStatus, CKCertificateChainTrustStatusRevokedLeaf);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testRevokedOCSPWithEngine:(CRYPTO_ENGINE)engine {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8408"];
    parameters.cryptoEngine = engine;
    parameters.checkCRL = false;
    parameters.checkOCSP = true;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testRevokedOCSP", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (RevokedCert)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (RevokedCert)");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        CKRevoked * status = certificates[0].revoked;
        XCTAssertNotNil(status);
        XCTAssertTrue(status.isRevoked);
        XCTAssertEqual(status.reason, CKRevokedReasonKeyCompromise);
        XCTAssertEqual(response.certificateChain.trustStatus, CKCertificateChainTrustStatusRevokedLeaf);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testExpiredLeafWithEngine:(CRYPTO_ENGINE)engine {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8410"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testExpiredLeaf", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (ExpiredLeaf)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (ExpiredLeaf)");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        XCTAssertTrue(certificates[0].isExpired);
        XCTAssertEqual(response.certificateChain.trustStatus, CKCertificateChainTrustStatusInvalidDate);
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testExpiredIntWithEngine:(CRYPTO_ENGINE)engine {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8411"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testExpiredInt", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        if (certificates.count >= 2) {
            // On systems where the root cert isn't trusted, the system doesn't include an expired intermediate in the chain - for some reason.
            XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
            XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (ExpiredInt)");
            XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
            XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (ExpiredInt)");
            if (certificates.count == 3) {
                XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
                XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
            }
            XCTAssertTrue(certificates[1].isExpired);
            XCTAssertEqual(response.certificateChain.trustStatus, CKCertificateChainTrustStatusInvalidDate);
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

+ (void) testTooManyHTTPHeadersWithEngine:(CRYPTO_ENGINE)engine {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8412"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testTooManyHTTPHeaders", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    NSNumber * __block passed = @NO;
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertGreaterThanOrEqual(certificates.count, 2, @"Chain must include at least 2 certificates");
        XCTAssertGreaterThan(certificates[0].subject.commonNames.count, 0);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (TooManyHTTPHeaders)");
        XCTAssertGreaterThan(certificates[1].subject.commonNames.count, 0);
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (TooManyHTTPHeaders)");
        if (certificates.count == 3) {
            XCTAssertGreaterThan(certificates[2].subject.commonNames.count, 0);
            XCTStringEqual(certificates[2].subject.commonNames[0], @"CertificateKit Root");
        }
        passed = @YES;
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TEST_TIMEOUT * NSEC_PER_SEC)));
    if (!passed.boolValue) {
        XCTFail("Timeout without error");
    }
}

@end
