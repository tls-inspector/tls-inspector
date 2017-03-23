#import "CertificateReminderManager.h"

@interface CertificateReminderManager() {
    void (^completedBlock)(NSError *, BOOL);
}

@end

@implementation CertificateReminderManager

- (void) addReminderForCertificate:(CKCertificate *)cert forDomain:(NSString *)domain daysBeforeExpires:(NSUInteger)days completed:(void (^)(NSError * error, BOOL success))completed {
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
