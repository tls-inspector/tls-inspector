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
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer != nil);
        XCTAssertEqual(response.httpServer.statusCode, 200);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertEqual(certificates.count, 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BasicHTTPS)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BasicHTTPS)");
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, DISPATCH_TIME_FOREVER);
}

- (void) testBareTLS {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8402"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testBareTLS", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertEqual(certificates.count, 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BareTLS)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BareTLS)");
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, DISPATCH_TIME_FOREVER);
}

- (void) testTooManyCerts {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8403"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testTooManyCerts", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        XCTStringEqual(error.localizedDescription, @"Too many certificates from server");
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, DISPATCH_TIME_FOREVER);
}

- (void) testNaughtyHTTP {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8404"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testNaughtyHTTP", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertEqual(certificates.count, 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (NaughtyHTTP)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (NaughtyHTTP)");
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, DISPATCH_TIME_FOREVER);
}

- (void) testFuzzHTTP {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8405"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testFuzzHTTP", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertEqual(certificates.count, 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (FuzzHTTP)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (FuzzHTTP)");
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, DISPATCH_TIME_FOREVER);
}

- (void) testFuzzTLS {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8406"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testFuzzTLS", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, DISPATCH_TIME_FOREVER);
}

- (void) testBigHTTPHeader {
    CKInspectParameters * parameters = [CKInspectParameters fromQuery:@"localhost:8407"];
    parameters.cryptoEngine = engine;
    CKInspectRequest * request = [CKInspectRequest requestWithParameters:parameters];
    dispatch_queue_t inspectQueue = dispatch_queue_create("testBigHTTPHeader", NULL);
    dispatch_semaphore_t sync = dispatch_semaphore_create(0);
    [request executeOn:inspectQueue completed:^(CKInspectResponse * response, NSError * error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertTrue(response.httpServer == nil);
        NSArray<CKCertificate *> * certificates = response.certificateChain.certificates;
        XCTAssertEqual(certificates.count, 2);
        XCTStringEqual(certificates[0].subject.commonNames[0], @"CertificateKit Leaf (BigHTTPHeader)");
        XCTStringEqual(certificates[1].subject.commonNames[0], @"CertificateKit Intermediate #1 (BigHTTPHeader)");
        dispatch_semaphore_signal(sync);
    }];
    dispatch_semaphore_wait(sync, DISPATCH_TIME_FOREVER);
}

@end
