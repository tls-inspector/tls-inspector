#import <Foundation/Foundation.h>

@interface NSAtomicNumber : NSObject

+ (NSAtomicNumber * _Nonnull) numberWithInitialValue:(NSInteger)initialValue;
- (NSInteger) getAndIncrement;
- (NSInteger) incrementAndGet;
- (NSInteger) getAndDecrement;
- (NSInteger) decrementAndGet;
- (NSInteger) getValue;
- (void) setValue:(NSInteger)value;

@end
