//
//  CKLogging.m
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

#import "CKLogging.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

@interface CKLogging ()

@property (strong, nonatomic) NSFileHandle * handle;

@end

static id _instance;
static dispatch_queue_t queue;

@implementation CKLogging

- (id) init {
    if (_instance == nil) {
        CKLogging * logging = [super init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        logging.file = [documentsDirectory stringByAppendingPathComponent:@"ckcertificate.log"];
        [logging createQueue];
#if DEBUG
        logging.level = CKLoggingLevelDebug;
#else
        logging.level = CKLoggingLevelInfo;
#endif
        _instance = logging;
    }
    return _instance;
}

- (id) initWithLogFile:(NSString *)file {
    self = [super init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.file = [documentsDirectory stringByAppendingPathComponent:file];
#if DEBUG
    self.level = CKLoggingLevelDebug;
#else
    self.level = CKLoggingLevelInfo;
#endif
    [self createQueue];
    return self;
}

- (void) createQueue {
    if (!queue) {
        queue = dispatch_queue_create("com.tlsinspector.CKCertificate", NULL);
    }
}

+ (CKLogging *) sharedInstance {
    if (!_instance) {
        _instance = [CKLogging new];
    }
    return _instance;
}

- (NSString *) stringForLevel:(CKLoggingLevel)level {
    switch (level) {
        case CKLoggingLevelDebug:
            return @"DEBUG";
        case CKLoggingLevelInfo:
            return @"INFO ";
        case CKLoggingLevelError:
            return @"ERROR";
        case CKLoggingLevelWarning:
            return @"WARN ";
    }
}

- (void) write:(NSString *)string forLevel:(CKLoggingLevel)level {
    dispatch_async(queue, ^{
        NSString * writeString = [NSString stringWithFormat:@"[%@][%ld] %@",
                                  [self stringForLevel:level], time(0), string];
        [self.handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
        printf("%s", [writeString UTF8String]);
    });
}

- (void) writeLine:(NSString *)string forLevel:(CKLoggingLevel)level {
    if (self.level >= level) {
        [self write:[NSString stringWithFormat:@"%@\n", string] forLevel:level];
    }
}

- (void) writeDebug:(NSString *)message {
    [self writeLine:message forLevel:CKLoggingLevelDebug];
}

- (void) writeInfo:(NSString *)message {
    [self writeLine:message forLevel:CKLoggingLevelInfo];
}

- (void) writeWarn:(NSString *)message {
    [self writeLine:message forLevel:CKLoggingLevelWarning];
}

- (void) writeError:(NSString *)message {
    [self writeLine:message forLevel:CKLoggingLevelError];
}

@end
