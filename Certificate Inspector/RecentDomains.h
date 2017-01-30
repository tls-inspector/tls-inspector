#import <Foundation/Foundation.h>

@interface RecentDomains : NSObject

- (NSArray<NSString *> *) getRecentDomains;
- (void) removeAllRecentDomains;
- (NSArray<NSString *> *) removeDomainAtIndex:(NSUInteger)index;
- (NSArray<NSString *> *) prependDomain:(NSString *)domain;
- (BOOL) saveRecentDomains;
- (void) setSaveRecentDomains:(BOOL)newValue;

@end
