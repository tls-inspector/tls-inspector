//
//  CKGetter.m
//
//  MIT License
//
//  Copyright (c) 2017 Ian Spence
//  https://tlsinspector.com/github.html
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

#import "CKGetter.h"
#import "CKServerInfoGetter.h"
#import "CKCertificateChainGetter.h"
#import "CKOpenSSLCertificateChainGetter.h"
#import "CKAppleCertificateChainGetter.h"

@interface CKGetter () <NSStreamDelegate, CKGetterTaskDelegate> {
    BOOL gotChain;
    BOOL gotServerInfo;
}

@property (strong, nonatomic, nonnull) CKCertificateChainGetter * chainGetter;
@property (strong, nonatomic, nonnull) CKServerInfoGetter * serverInfoGetter;
@property (strong, nonatomic, nonnull) NSArray<CKGetterTask *> * tasks;
@property (nonatomic) BOOL didCallFinished;
@property (strong, nonatomic) NSObject * finishedMutex;

@end

@implementation CKGetter

typedef NS_ENUM(NSUInteger, CKGetterTaskTag) {
    CKGetterTaskTagChain,
    CKGetterTaskTagServerInfo,
};

+ (CKGetter *) getterWithOptions:(CKGetterOptions *)options {
    CKGetter * getter = [CKGetter new];
    getter.options = options;
    return getter;
}

- (void) getInfoForURL:(NSURL *)URL; {
    PDebug(@"Starting getter for: %@", URL.absoluteString);

    self.url = URL;

    if (self.options.useOpenSSL) {
        self.chainGetter = [CKOpenSSLCertificateChainGetter new];
    } else {
        self.chainGetter = [CKAppleCertificateChainGetter new];
    }

    self.chainGetter.delegate = self;
    self.chainGetter.tag = CKGetterTaskTagChain;
    self.chainGetter.options = self.options;

    self.serverInfoGetter = [CKServerInfoGetter new];
    self.serverInfoGetter.delegate = self;
    self.serverInfoGetter.tag = CKGetterTaskTagServerInfo;
    self.finishedMutex = [NSObject new];

    NSMutableArray<CKGetterTask *> * tasks = [NSMutableArray arrayWithCapacity:2];
    [tasks addObject:self.chainGetter];
    if (self.options.queryServerInfo) {
        [tasks addObject:self.serverInfoGetter];
    }
    self.tasks = tasks;

    for (CKGetterTask * task in self.tasks) {
        [NSThread detachNewThreadSelector:@selector(performTaskForURL:) toTarget:task withObject:URL];
    }
}

- (void) getter:(CKGetterTask *)getter finishedTaskWithResult:(id)data {
    switch (getter.tag) {
        case CKGetterTaskTagChain:
            PDebug(@"Certificate chain task finished");
            self.chain = (CKCertificateChain *)data;
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:gotCertificateChain:)]) {
                [self.delegate getter:self gotCertificateChain:self.chain];
            }
            break;
        case CKGetterTaskTagServerInfo:
            PDebug(@"Server info task finished");
            self.serverInfo = (CKServerInfo *)data;
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:gotServerInfo:)]) {
                [self.delegate getter:self gotServerInfo:self.serverInfo];
            }
            break;
        default:
            break;
    }
    
    [self checkIfFinished];
}

- (void) getter:(CKGetterTask *)getter failedTaskWithError:(NSError *)error {
    switch (getter.tag) {
        case CKGetterTaskTagChain:
            PDebug(@"Certificate chain task failed");
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:errorGettingCertificateChain:)]) {
                [self.delegate getter:self errorGettingCertificateChain:error];
            }
            break;
        case CKGetterTaskTagServerInfo:
            PDebug(@"Server info task failed");
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:errorGettingServerInfo:)]) {
                [self.delegate getter:self errorGettingServerInfo:error];
            }
            break;
        default:
            break;
    }

    [self checkIfFinished];
}

- (void) checkIfFinished {
    PDebug(@"Checking if all tasks are finished");
    BOOL allFinished = YES;
    BOOL allSuccessful = YES;
    for (CKGetterTask * task in self.tasks) {
        if (!task.finished) {
            switch (task.tag) {
                case CKGetterTaskTagChain:
                    PDebug(@"Certificate chain task not finished");
                    break;
                case CKGetterTaskTagServerInfo:
                    PDebug(@"Server info task not finished");
                    break;
                default:
                    PDebug(@"Unknown task (%u) not finished", (unsigned int)task.tag);
                    break;
            }
            allFinished = NO;
            break;
        }
        if (!task.successful) {
            switch (task.tag) {
                case CKGetterTaskTagChain:
                    PDebug(@"Certificate chain task failed");
                    break;
                case CKGetterTaskTagServerInfo:
                    PDebug(@"Server info task failed");
                    break;
                default:
                    PDebug(@"Unknown task (%u) failed", (unsigned int)task.tag);
                    break;
            }
            allSuccessful = NO;
            break;
        }
    }
    @synchronized (self.finishedMutex) {
        if (allFinished && !self.didCallFinished) {
            self.didCallFinished = YES;
            PDebug(@"Getter finished all tasks");
            if (!self.delegate) {
                return;
            }
            if (![self.delegate respondsToSelector:@selector(finishedGetter:successful:)]) {
                return;
            }
            [self.delegate finishedGetter:self successful:allSuccessful];
        }
    }
}

@end
