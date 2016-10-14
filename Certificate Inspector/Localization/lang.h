#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface lang : NSObject

/**
 *  Translate the specified key into the users current language
 *
 *  @param key The string key
 *
 *  @return The translated value or the key if the value is not found
 */
+ (NSString *) key:(NSString *)key;

/**
 *  Translate the specified key with arguments formatted into the users current language
 *
 *  @param key  The string key
 *  @param args The argument as string
 *
 *  @return The translated value or the key if the value is not found
 */
+ (NSString *) key:(NSString *)key
              args:(NSArray<NSString *> *)args;

/**
 *  Translate the specified key into the given langauge
 *
 *  @param key      The string key
 *  @param language The language
 *
 *  @return The translated value or the key if the value is not found
 */
+ (NSString *) key:(NSString *)key
       forLanguage:(NSString *)language;

/**
 *  Translate the specified key with arguments formatted into the given langauge
 *
 *  @param key  The string key
 *  @param language The language
 *  @param args The argument as string
 *
 *  @return The translated value or the key if the value is not found
 */
+ (NSString *) key:(NSString *)key
              args:(NSArray<NSString *> *)args
       forLanguage:(NSString *)language;

// These singletons need to be public but should not be used
+ (NSString *) key:(NSString *)key
              dict:(NSDictionary *)dict;

+ (NSString *) key:(NSString *)key
              args:(NSArray<NSString *> *)args
              dict:(NSDictionary *)dict;
+ (void) loadDict;

@end
