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
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    self.file = [documentsDirectory stringByAppendingPathComponent:file];
    [self createQueue];
    [self open];
#if DEBUG
    self.level = CKLoggingLevelDebug;
#else
    self.level = CKLoggingLevelWarning;
#endif
    return self;
}

- (void) createQueue {
    if (!queue) {
        queue = dispatch_queue_create("com.tlsinspector.CKCertificate.CKLogging", NULL);
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
#ifndef DEBUG
    _level = level;
    [self writeDebug:[NSString stringWithFormat:@"Setting log level to: %@ (%lu)", [self stringForLevel:level], (unsigned long)level]];
#endif
}

@end
