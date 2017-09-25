#import "NSAtomicNumber.h"

@interface NSAtomicNumber()

@property (nonatomic) NSInteger curValue;

@end

@implementation NSAtomicNumber

static id semaphore;

+ (NSAtomicNumber * _Nonnull) numberWithInitialValue:(NSInteger)initialValue {
    NSAtomicNumber * number = [NSAtomicNumber new];
    semaphore = @0;
    number.curValue = initialValue;
    return number;
}

- (NSInteger) getAndIncrement {
    @synchronized(semaphore) {
        NSInteger currentValue = self.curValue;
        self.curValue ++;
        return currentValue;
    }
}

- (NSInteger) incrementAndGet {
    @synchronized(semaphore) {
        self.curValue ++;
        return self.curValue;
    }
}

- (NSInteger) getAndDecrement {
    @synchronized(semaphore) {
        NSInteger currentValue = self.curValue;
        self.curValue --;
        return currentValue;
    }
}

- (NSInteger) decrementAndGet {
    @synchronized(semaphore) {
        self.curValue --;
        return self.curValue;
    }
}

- (NSInteger) getValue {
    @synchronized(semaphore) {
        return self.curValue;
    }
}

- (void) setValue:(NSInteger)value {
    @synchronized(semaphore) {
        self.curValue = value;
    }
}

- (NSString *) description {
    @synchronized(semaphore) {
        return [NSString stringWithFormat:@"%li", (long)self.curValue];
    }
}

@end
