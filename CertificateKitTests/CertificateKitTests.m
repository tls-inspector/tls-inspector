#import <XCTest/XCTest.h>
@import CertificateKit;

@interface CertificateKitTests : XCTestCase

@property (strong, nonatomic) CKCertificateChain * chainGetter;

@end

@implementation CertificateKitTests

- (void)setUp {
    self.chainGetter = [CKCertificateChain new];
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

# pragma mark - Simple gets

/**
 Get the specified URL and perform basic tests on the chain

 @param url The URL to query
 @param finished Called when finished with an error or nil
 */
- (void) runGetter:(NSURL *)url finished:(void (^)(NSError * error))finished {
    [self.chainGetter
     certificateChainFromURL:url
     finished:^(NSError * _Nullable error, CKCertificateChain * _Nullable chain) {
         XCTAssertNil(error, @"Should get chain for domain %@ without error", url.absoluteString);
         XCTAssert(chain.certificates.count > 0, @"Chain should contain at least 1 certificate");
         if (finished) {
             finished(error);
         }
     }];
}

/**
 Test a single domain.
 Tests:
  - Can get domain without error
  - Certificate chain contains more than 1 certificate
 */
- (void) testSingleDomain {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Getting certificates for single domain"];

    [self runGetter:[NSURL URLWithString:@"https://www.google.com/"] finished:^(NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 Test a single IP.
 Tests:
 - Can get domain without error
 - Certificate chain contains more than 1 certificate
 */
- (void) testSingleIP {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Getting certificates for single domain"];
    [self runGetter:[NSURL URLWithString:@"https://93.184.216.34/"] finished:^(NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 Test multiple domains.
 Tests:
 - Can get eact domain without error
 - Certificate chain contains more than 1 certificate for each domain
 */
- (void) testMultipleDomains {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Getting certificates for single domain"];

    [self runGetter:[NSURL URLWithString:@"https://www.googe.com/"] finished:^(NSError *error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];

#define testURL(__url) expectation = [self expectationWithDescription:@"Getting certificates for single domain"]; \
[self runGetter:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/", __url]] finished:^(NSError *error) { \
[expectation fulfill]; \
}]; \
[self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) { \
if (error) { \
XCTFail(@"Expectation Failed with error: %@", error); \
} \
}];

    testURL(@"aliexpress.com");
    testURL(@"amazon.com");
    testURL(@"ebay.com");
    testURL(@"facebook.com");
    testURL(@"imgur.com");
    testURL(@"instagram.com");
    testURL(@"linkedin.com");
    testURL(@"live.com");
    testURL(@"netflix.com");
    testURL(@"reddit.com");
    testURL(@"tlsinspector.com");
    testURL(@"tumblr.com");
    testURL(@"twitch.tv");
    testURL(@"twitter.com");
    testURL(@"wikipedia.org");
    testURL(@"wordpress.com");
    testURL(@"www.apple.com");
    testURL(@"www.nsa.gov");
    testURL(@"yahoo.com");
    testURL(@"youtube.com");

}

# pragma - Feature tests

/**
 Test CRL functionality

 Tests:
  - Revoked server certificate is marked as such
  - Chain is not trusted
 */
- (void) testCRL {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Getting certificates for single domain"];

    [self.chainGetter
     certificateChainFromURL:[NSURL URLWithString:@"https://revoked.badssl.com/"]
     finished:^(NSError * _Nullable error, CKCertificateChain * _Nullable chain) {
         XCTAssertTrue(chain.server.revoked.isRevoked, @"Server certificate should be revoked");
         XCTAssertTrue(chain.trusted == CKCertificateChainTrustStatusRevoked,
                       @"Chain with revoked server certificate should not be trusted");
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 Test expired certificate functionality

 Tests:
  - Server certificate should have invalid issue date
  - Chain with expired server certificate should not be trusted
 */
- (void) testExpired {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Getting certificates for single domain"];

    [self.chainGetter
     certificateChainFromURL:[NSURL URLWithString:@"https://expired.badssl.com/"]
     finished:^(NSError * _Nullable error, CKCertificateChain * _Nullable chain) {
         XCTAssertFalse(chain.server.validIssueDate, @"Server certificate should have invalid issue date");
         XCTAssertTrue(chain.trusted == CKCertificateChainTrustStatusUntrusted,
                       @"Chain with expired server certificate should not be trusted");
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 Test self-signed certificate functionality

 Tests:
  - Self signed certificate chain should only have 1 certificate
  - No intermediate CA should be present for self-signed chain
  - No server CA should be present for self-signed chain
  - Chain with expired server certificate should not be trusted
 */
- (void) testSelfSigned {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Getting certificates for single domain"];

    [self.chainGetter
     certificateChainFromURL:[NSURL URLWithString:@"https://self-signed.badssl.com/"]
     finished:^(NSError * _Nullable error, CKCertificateChain * _Nullable chain) {
         XCTAssertTrue(chain.certificates.count == 1, @"Self signed certificate chain should only have 1 certificate");
         XCTAssertNil(chain.intermediateCA, @"No intermediate CA should be present for self-signed chain");
         XCTAssertNil(chain.rootCA, @"No server CA should be present for self-signed chain");
         XCTAssertTrue(chain.trusted == CKCertificateChainTrustStatusSelfSigned,
                       @"Chain with expired server certificate should not be trusted");
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 Test RSA public key functionality

 Tests:
 - Should have 2048bit length public key
 - Should have RSA type public key
 */
- (void) testRSAPublicKey {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Getting certificates for single domain"];

    [self.chainGetter
     certificateChainFromURL:[NSURL URLWithString:@"https://rsa2048.badssl.com/"]
     finished:^(NSError * _Nullable error, CKCertificateChain * _Nullable chain) {
         XCTAssertTrue(chain.server.publicKey.bitLength == 2048, @"Should have 2048bit length public key");
         XCTAssertTrue([chain.server.publicKey.algroithm isEqualToString:@"rsaEncryption"],
                       @"Should have RSA type public key");
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 Test ECDSA public key functionality

 Tests:
 - Should have 256bit length public key
 - Should have ECDSA type public key
 */
- (void) testECPublicKey {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Getting certificates for single domain"];

    [self.chainGetter
     certificateChainFromURL:[NSURL URLWithString:@"https://ecc256.badssl.com/"]
     finished:^(NSError * _Nullable error, CKCertificateChain * _Nullable chain) {
         XCTAssertTrue(chain.server.publicKey.bitLength == 256, @"Should have 256bit length public key");
         XCTAssertTrue([chain.server.publicKey.algroithm isEqualToString:@"id-ecPublicKey"],
                       @"Should have RSA type public key");
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 Test RSA public key functionality

 Tests:
 - Should negotiate ECDHE ECDSA with AES 128 GCM SHA256 cipher suite
 - Shoud negotiate protocol TLS1.2
 */
- (void) testNegotiations {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Getting certificates for single domain"];

    [self.chainGetter
     certificateChainFromURL:[NSURL URLWithString:@"https://ecc256.badssl.com/"]
     finished:^(NSError * _Nullable error, CKCertificateChain * _Nullable chain) {
         XCTAssertTrue(chain.cipher == TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
                       @"Should negotiate ECDHE ECDSA with AES 128 GCM SHA256 cipher suite");
         XCTAssertTrue(chain.protocol == kTLSProtocol12,
                       @"Shoud negotiate protocol TLS1.2");
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
