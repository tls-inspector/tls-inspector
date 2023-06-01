#import "NSString+SplitFirst.h"

@implementation NSString (SPLIT_FIRST)

- (NSArray<NSString *> *) splitFirst:(NSString *)sep {
    NSArray<NSString *> * parts = [self componentsSeparatedByString:sep];
    if (parts.count <= 2) {
        return parts;
    }

    NSMutableArray<NSString *> * ret = [NSMutableArray arrayWithCapacity:2];
    [ret insertObject:parts[0] atIndex:0];
    [ret insertObject:[[parts subarrayWithRange:NSMakeRange(1, parts.count-2)] componentsJoinedByString:sep] atIndex:1];
    return ret;
}

@end
