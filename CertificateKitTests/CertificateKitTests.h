#ifndef CertificateKitTests_h
#define CertificateKitTests_h

#define XCTAssertStringEqual(s1, s2) XCTAssertTrue([s1 isEqualToString:s2], @"'%@'(%lu) not equal to '%@'(%lu)", s1, s1.length, s2, s2.length);

#endif
