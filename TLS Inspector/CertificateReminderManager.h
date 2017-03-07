#import <Foundation/Foundation.h>
#import "CHCertificate.h"
@import EventKit;

@interface CertificateReminderManager : NSObject

- (void) addReminderForCertificate:(CHCertificate *)cert forDomain:(NSString *)domain daysBeforeExpires:(NSUInteger)days completed:(void (^)(NSError * error, BOOL success))completed;

@end
