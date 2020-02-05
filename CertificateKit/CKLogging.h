//
//  CKLogging.h
//
//  MIT License
//
//  Copyright (c) 2018 Ian Spence
//  https://github.com/certificate-helper/CertificateKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "CertificateKit.h"

/// The certificate kit logging class
@interface CKLogging : NSObject

/**
 Logging levels for the certificate kit log

 - CKLoggingLevelDebug: Debug logs will include all information sent to the log instance,
                        including domain names. Use with caution.
 - CKLoggingLevelInfo: Informational logs for irregular, but not dangerous events.
 - CKLoggingLevelWarning: Warning logs for dangerous, but not fatal events.
 - CKLoggingLevelError: Error events for when things really go sideways.
 */
typedef NS_ENUM(NSUInteger, CKLoggingLevel) {
    CKLoggingLevelDebug = 0,
    CKLoggingLevelInfo,
    CKLoggingLevelWarning,
    CKLoggingLevelError,
};

/// The shared instance of the CKLogging class
+ (CKLogging * _Nonnull) sharedInstance;

/// The current logging level
@property (nonatomic) CKLoggingLevel level;
/// The filepath of the log file
@property (strong, nonatomic, nonnull) NSString * file;

/// Write a DEBUG level message
/// @param message The message to write
- (void) writeDebug:(NSString * _Nonnull)message;
/// Write an INFO level message
/// @param message The message to write
- (void) writeInfo:(NSString * _Nonnull)message;
/// Write a WARN level message
/// @param message The message to write
- (void) writeWarn:(NSString * _Nonnull)message;
/// Write an ERROR level message
/// @param message The message to write
- (void) writeError:(NSString * _Nonnull)message;

@end
