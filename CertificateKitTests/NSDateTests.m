#import <XCTest/XCTest.h>
#import "CertificateKitTests.h"
#import "../CertificateKit/Extensions/NSDate+ASN1_TIME.h"
#import "../CertificateKit/Extensions/NSDate+GeneralizedTime.h"

@interface NSDateTests : XCTestCase

@end

@implementation NSDateTests

- (void) setUp {
    [super setUp];
}

- (void) tearDown {
    [super tearDown];
}

- (void) testParseASN1GeneralizedTime {
    NSArray<NSArray<NSString *> *> * tests = @[
        @[ @"20231228175051+0530", @"2023-12-28T04:20:51-08:00" ],
        @[ @"20230516112418-0400", @"2023-05-16T07:24:18-08:00" ],
        @[ @"20231210010203Z",     @"2023-12-09T17:02:03-08:00" ],
    ];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-28800]];
    [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];

    for (NSArray<NSString *> * test in tests) {
        NSDate * date = [NSDate fromASN1GeneralizedTime:test[0]];
        XCTAssertNotNil(date);
        NSString * result = [dateFormatter stringFromDate:date];
        XCTAssertStringEqual(result, test[1]);
    }
}

@end
