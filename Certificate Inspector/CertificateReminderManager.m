//
//  CertificateReminderManager.m
//  Certificate Inspector
//
//  GPLv3 License
//  Copyright (c) 2017 Ian Spence
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

#import "CertificateReminderManager.h"

@interface CertificateReminderManager() {
    void (^completedBlock)(NSError *, BOOL);
}

@end

@implementation CertificateReminderManager

- (void) addReminderForCertificate:(CHCertificate *)cert forDomain:(NSString *)domain daysBeforeExpires:(NSUInteger)days completed:(void (^)(NSError * error, BOOL success))completed {
    completedBlock = completed;

    EKEventStore * store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        if (!granted || error) {
            completed(error, NO);
            return;
        }
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"MMM d, yyyy";
        
        NSString * host = [NSURL URLWithString:domain].host;
        
        EKReminder * reminder = [EKReminder reminderWithEventStore:store];
        
        reminder.title = lv(@"Renew Certificate for {domain}", @[host]);
        reminder.notes = [lang key:@"The certificate for {domain} expires on {date}" args:@[host, [formatter stringFromDate:[cert notAfter]]]];
        reminder.URL = [NSURL URLWithString:[NSString stringWithFormat:@"certinspector://%@", domain]];
        
        NSDate * alarmDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                      value:-days
                                                                     toDate:[cert notAfter]
                                                                    options:0];
        
        [reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:alarmDate]];

        EKCalendar * defaultReminderList = [store defaultCalendarForNewReminders];
        [reminder setCalendar:defaultReminderList];
        NSError * saveError;
        BOOL success = [store saveReminder:reminder commit:YES error:&saveError];
        completed(saveError, success);
    }];
}

@end
