//
//  RecentDomains.m
//  Certificate Inspector
//
//  GPLv3 License
//  Copyright (c) 2016 Ian Spence
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
