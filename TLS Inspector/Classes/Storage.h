#import <Foundation/Foundation.h>

/**
 Singleton class for storing user preferences.
 */
@interface Storage : NSObject

/**
 Get the shared instance of the storage singleton

 @return A storage instance.
 */
+ (Storage * _Nonnull) sharedInstance;

/**
 The user defaults for the app
 */
@property (strong, nonatomic) NSUserDefaults * groupDefaults;

@end
