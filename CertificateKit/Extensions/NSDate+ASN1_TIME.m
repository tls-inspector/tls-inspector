//
//  NSDate+ASN1_TIME.m
//
//  LGPLv3
//
//  Copyright (c) 2017 Ian Spence
//  https://tlsinspector.com/github.html
//
//  This library is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with this library.  If not, see <https://www.gnu.org/licenses/>.

#import <CertificateKit/NSDate+ASN1_TIME.h>
#import <openssl/ossl_typ.h>
#import <openssl/asn1.h>

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
