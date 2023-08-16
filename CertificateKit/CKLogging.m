//
//  CKLogging.m
//
//  LGPLv3
//
//  Copyright (c) 2018 Ian Spence
//  https://tlsinspector.com/github.html
//
//  This library is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with this library.  If not, see <https://www.gnu.org/licenses/>.

#import "CKLogging.h"
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <openssl/err.h>

@interface CKLogging ()

@property (strong, nonatomic) NSObject * lock;
@property (strong, nonatomic) NSFileHandle * handle;

@end

static id _instance;

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
        self.lock = [NSObject new];
    }
    return _instance;
}

- (id) initWithLogFile:(NSString *)file {
    self = [super init];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    self.file = [documentsDirectory stringByAppendingPathComponent:file];
    [self open];
#if DEBUG
    self.level = CKLoggingLevelDebug;
#else
    self.level = CKLoggingLevelWarning;
#endif
    return self;
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

- (void) truncateLogs {
    @synchronized (self.lock) {
        [self.handle closeFile];
        [[NSFileManager defaultManager] removeItemAtPath:self.file error:nil];
        [self open];
    }
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
    NSString * thread = [NSString stringWithFormat:@"%p", NSThread.currentThread];
    @synchronized (self.lock) {
        NSString * writeString = [NSString stringWithFormat:@"[%@][%ld][%@] %@",
                                  [self stringForLevel:level], time(0), thread, string];
        [self.handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
        printf("%s", [writeString UTF8String]);
    }
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
#ifndef DEBUG
    _level = level;
    [self writeDebug:[NSString stringWithFormat:@"Setting log level to: %@ (%lu)", [self stringForLevel:level], (unsigned long)level]];
#endif
}

+ (void) captureOpenSSLErrorInFile:(const char *)file line:(int)line {
    const char * opensslFile = NULL;
    int opensslLine;
    ERR_peek_last_error_line(&opensslFile, &opensslLine);
    if (file != NULL) {
        [CKLogging.sharedInstance writeError:[NSString stringWithFormat:@"%s:%i OpenSSL error occurred in file %s:%i", file, line, opensslFile, opensslLine]];
    } else {
        [CKLogging.sharedInstance writeError:[NSString stringWithFormat:@"%s:%i OpenSSL error occurred but no file found", file, line]];
    }
}

@end
