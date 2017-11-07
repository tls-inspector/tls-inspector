#import "Storage.h"

@interface Storage ()

@end

@implementation Storage

static Storage * _instance;
#define SUITE_NAME @"group.com.ecnepsnai.Certificate-Inspector"

+ (Storage *) sharedInstance {
    if (!_instance) {
        _instance = [Storage new];
        _instance.groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:SUITE_NAME];
    }
    return _instance;
}

- (id) init {
    if (!_instance) {
        _instance = [super init];
    }
    return _instance;
}

@end
