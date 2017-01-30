#import "RecentDomains.h"

@interface RecentDomains() {
    NSUserDefaults * defaults;
}
@end

@implementation RecentDomains

- (id) init {
    self = [super init];
    defaults = [NSUserDefaults standardUserDefaults];
    return self;
}

- (NSArray<NSString *> *) getRecentDomains {
    NSArray * recents = [defaults arrayForKey:RECENT_DOMAINS_KEY];
    return recents ?: @[];
}

- (void) removeAllRecentDomains {
    [defaults setObject:@[] forKey:RECENT_DOMAINS_KEY];
}

- (NSArray<NSString *> *) removeDomainAtIndex:(NSUInteger)index {
    NSMutableArray * recents = [self recents];
    [recents removeObjectAtIndex:index];
    [self save:recents];
    return recents;
}

- (NSArray<NSString *> *) prependDomain:(NSString *)domain {
    NSMutableArray * recents = [self recents];
    [recents insertObject:domain atIndex:0];
    if (recents.count > 4) {
        [recents removeLastObject];
    }
    [self save:recents];
    return recents;
}

- (NSMutableArray *) recents {
    return [NSMutableArray arrayWithArray:[self getRecentDomains]];
}

- (void) save:(NSArray<NSString *> *)recents {
    [defaults setObject:recents forKey:RECENT_DOMAINS_KEY];
}



- (BOOL) saveRecentDomains {
    return [defaults boolForKey:SAVE_RECENT_DOMAINS];
}

- (void) setSaveRecentDomains:(BOOL)newValue {
    [defaults setBool:newValue forKey:SAVE_RECENT_DOMAINS];
    if (!newValue) {
        [self removeAllRecentDomains];
    }
}

@end
