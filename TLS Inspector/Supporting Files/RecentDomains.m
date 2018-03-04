#import "RecentDomains.h"

@interface RecentDomains()

@end

@implementation RecentDomains

static id _instance;

+ (RecentDomains *) sharedInstance {
    if (!_instance) {
        _instance = [RecentDomains new];
    }
    return _instance;
}

- (id) init {
    if (!_instance) {
        _instance = [super init];
        return self;
    }
    
    return _instance;
}

- (NSArray<NSString *> *) getRecentDomains {
    NSArray * recents = [AppDefaults arrayForKey:RECENT_DOMAINS_KEY];
    return recents ?: @[];
}

- (void) removeAllRecentDomains {
    [AppDefaults setObject:@[] forKey:RECENT_DOMAINS_KEY];
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
    [AppDefaults setObject:recents forKey:RECENT_DOMAINS_KEY];
}

- (BOOL) saveRecentDomains {
    return UserOptions.currentOptions.rememberRecentLookups;
}

- (void) setSaveRecentDomains:(BOOL)newValue {
    UserOptions.currentOptions.rememberRecentLookups = newValue;
    if (!newValue) {
        [self removeAllRecentDomains];
    }
}

@end
