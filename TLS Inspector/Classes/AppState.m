#import "AppState.h"

@implementation AppState

static id _instance;

+ (AppState *) currentState {
    if (!_instance) {
        _instance = [AppState new];
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
