#import <Foundation/Foundation.h>
@import EventKit;

@interface CertificateReminderManager : NSObject

- (void) addReminderForCertificate:(CKCertificate *)cert forDomain:(NSString *)domain daysBeforeExpires:(NSUInteger)days completed:(void (^)(NSError * error, BOOL success))completed;

@end
