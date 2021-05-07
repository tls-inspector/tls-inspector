#import "NSDate+ASN1_TIME.h"
#include <openssl/ossl_typ.h>
#include <openssl/asn1.h>

@implementation NSDate (ASN1_TIME)

+ (NSDate *) fromASN1_TIME:(const void *)asn {
    // Source: http://stackoverflow.com/a/8903088/1112669
    ASN1_GENERALIZEDTIME * certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime((ASN1_TIME *)asn, NULL);
    if (certificateExpiryASN1Generalized != NULL) {
        const unsigned char * certificateExpiryData = ASN1_STRING_get0_data(certificateExpiryASN1Generalized);

        // ASN1 generalized times look like this: "20131114230046Z"
        //                                format:  YYYYMMDDHHMMSS
        //                               indices:  01234567890123
        //                                                   1111
        // There are other formats (e.g. specifying partial seconds or
        // time zones) but this is good enough for our purposes since
        // we only use the date and not the time.
        //
        // (Source: http://www.obj-sys.com/asn1tutorial/node14.html)

        NSString *expiryTimeStr = [NSString stringWithUTF8String:(char *)certificateExpiryData];
        NSDateComponents *expiryDateComponents = [[NSDateComponents alloc] init];

        expiryDateComponents.year   = [[expiryTimeStr substringWithRange:NSMakeRange(0, 4)]
                                       intValue];
        expiryDateComponents.month  = [[expiryTimeStr substringWithRange:NSMakeRange(4, 2)]
                                       intValue];
        expiryDateComponents.day    = [[expiryTimeStr substringWithRange:NSMakeRange(6, 2)]
                                       intValue];
        expiryDateComponents.hour   = [[expiryTimeStr substringWithRange:NSMakeRange(8, 2)]
                                       intValue];
        expiryDateComponents.minute = [[expiryTimeStr substringWithRange:NSMakeRange(10, 2)]
                                       intValue];
        expiryDateComponents.second = [[expiryTimeStr substringWithRange:NSMakeRange(12, 2)]
                                       intValue];

        ASN1_GENERALIZEDTIME_free(certificateExpiryASN1Generalized);
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        return [calendar dateFromComponents:expiryDateComponents];
    }
    return nil;
}

@end
