#import <Foundation/Foundation.h>

/**
 Describes the user configurable options.
 Property getter and setters directly reference user defaults.
 */
@interface UserOptions : NSObject

/**
 Returns the current set of user options

 @return A shared user options instance
 */
+ (UserOptions * _Nonnull) currentOptions;
/**
 Apply default values for missing keys. Won't overwrite any changes by the user.
 */
+ (void) setDefaultValues;

/**
 Should the app remember up to 5 of the last recently inspected domains?
 */
@property (nonatomic) BOOL rememberRecentLookups;
/**
 Should the app use the light theme?
 */
@property (nonatomic) BOOL useLightTheme;
/**
 Should the app show tips on the main screen?
 */
@property (nonatomic) BOOL showTips;
/**
 Should the app query the OCSP responder for a certificate?
 */
@property (nonatomic) BOOL queryOCSP;
/**
 Should the app download and check CRLs?
 */
@property (nonatomic) BOOL checkCRL;

@end
