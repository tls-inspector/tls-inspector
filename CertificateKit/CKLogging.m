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

+ (CKLogging *) sharedInstance {
    if (!_instance) {
        _instance = [CKLogging new];
    }
    return _instance;
}

- (id) init {
    if (_instance == nil) {
        _instance = [[CKLogging alloc] initWithLogFile:@"CertificateKit.log"];
    }
    return _instance;
}

- (id) initWithLogFile:(NSString *)file {
    self = [super init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.file = [documentsDirectory stringByAppendingPathComponent:file];
    [self createQueue];
    [self open];
    self.level = CKLoggingLevelInfo;
    return self;
}

- (void) createQueue {
    if (!queue) {
        queue = dispatch_queue_create("com.tlsinspector.CKCertificate", NULL);
    }
}

- (void) open {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.file]) {
        [[NSFileManager defaultManager] createFileAtPath:self.file contents:nil attributes:nil];
    }
    
    self.handle = [NSFileHandle fileHandleForWritingAtPath:self.file];
    [self.handle seekToEndOfFile];
}

- (void) appWillTerminate:(NSNotification *)n {
    [self close];
}

- (void) close {
    [self.handle closeFile];
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
    NSString * thread = [NSThread currentThread].description;
    dispatch_async(queue, ^{
        NSString * writeString = [NSString stringWithFormat:@"[%@][%ld][%@] %@",
                                  [self stringForLevel:level], time(0), thread, string];
        [self.handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
        printf("%s", [writeString UTF8String]);
    });
}

- (void) writeLine:(NSString *)string forLevel:(CKLoggingLevel)level {
    if (self.level <= level) {
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

- (void) setLevel:(CKLoggingLevel)level {
    _level = level;
    [self writeDebug:[NSString stringWithFormat:@"Setting log level to: %@ (%lu)", [self stringForLevel:level], (unsigned long)level]];
}

@end
