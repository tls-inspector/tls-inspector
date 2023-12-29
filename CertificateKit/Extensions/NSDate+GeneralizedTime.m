//
//  NSDate+GeneralizedTime.h
//
//  LGPLv3
//
//  Copyright (c) 2023 Ian Spence
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

#import "NSDate+GeneralizedTime.h"

@implementation NSDate (GeneralizedTime)

+ (NSDate *) fromASN1GeneralizedTime:(NSString *)generalizedTime {
    // ASN.1 Generalized time, as defined in ITU-T X.680, is a string representing
    // a fixed date and optional time (or varying precision).
    //
    // At minimum, a generalized time string must include yyyyMMdd
    // but can also optionally include:
    // - two digit hours (hh)
    // - two digit minutes (mm)
    // - two digit seconds (ss)
    // - UTC offset OR 'Z'
    // Written out, that's: yyyyMMdd[hh[mm[ss]]][Z]
    //
    // The timezone can be specified by a difference from UTC represented by 2 digits for hours and
    // 2 digits for minutes., or by the single character 'Z' for UTC. The 2 digits for minutes can be
    // omitted if the difference from UTC is only in whole hours.
    //
    // To avoid a mess of complexity, CertificateKit only supports the most commonly used formats of:
    // - Date only: yyyyMMdd
    // - Date & time with timezone: yyyyMMddhhmmssZ
    // For the timezone, we only support either UTC 'Z' for a hour and minute difference.

    if (generalizedTime.length < 8) {
        return nil;
    }

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    dateComponents.year = [[generalizedTime substringWithRange:NSMakeRange(0, 4)] intValue];
    dateComponents.month = [[generalizedTime substringWithRange:NSMakeRange(4, 2)] intValue];
    dateComponents.day = [[generalizedTime substringWithRange:NSMakeRange(6, 2)] intValue];
    dateComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

    if (generalizedTime.length <= 14) {
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;

        return dateComponents.date;
    }

    dateComponents.hour = [[generalizedTime substringWithRange:NSMakeRange(8, 2)] intValue];
    dateComponents.minute = [[generalizedTime substringWithRange:NSMakeRange(10, 2)] intValue];
    dateComponents.second = [[generalizedTime substringWithRange:NSMakeRange(12, 2)] intValue];

    if ([generalizedTime characterAtIndex:14] == 'Z' || generalizedTime.length != 19) {
        return dateComponents.date;
    }

    NSInteger secondsFromUtc = 0;
    BOOL beforeUTC = [generalizedTime characterAtIndex:14] == '+';

    int hoursFromUtc = [[generalizedTime substringWithRange:NSMakeRange(15, 2)] intValue];
    int minutesFromUtc = [[generalizedTime substringWithRange:NSMakeRange(17, 2)] intValue];

    secondsFromUtc = (hoursFromUtc * 3600) + (minutesFromUtc * 60);
    if (!beforeUTC) {
        secondsFromUtc=-secondsFromUtc;
    }
    dateComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:secondsFromUtc];

    return dateComponents.date;
}

@end
