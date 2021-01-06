//
//  CKGetter.m
//
//  LGPLv3
//
//  Copyright (c) 2017 Ian Spence
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

#import "CKGetter.h"
#import "CKServerInfoGetter.h"
#import "CKCertificateChainGetter.h"
#import "CKOpenSSLCertificateChainGetter.h"
#import "CKNetworkCertificateChainGetter.h"
#import "CKSecureTransportCertificateChainGetter.h"

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
    if (@available(iOS 12, *)) {} else {
        if (self.options.cryptoEngine == CRYPTO_ENGINE_NETWORK_FRAMEWORK) {
            PError(@"NetworkFramework crypto engine selected on incompatible iOS version - aborting");
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:unexpectedError:)]) {
                [self.delegate getter:self unexpectedError:[NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKGetter" code:200 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported crypto engine"}]];
            }
            return;
        }
    }

    PDebug(@"Starting getter for: %@", URL.absoluteString);

    self.url = URL;

    switch (self.options.cryptoEngine) {
        case CRYPTO_ENGINE_NETWORK_FRAMEWORK:
            self.chainGetter = [CKNetworkCertificateChainGetter new];
            break;
        case CRYPTO_ENGINE_SECURE_TRANSPORT:
            self.chainGetter = [CKSecureTransportCertificateChainGetter new];
            break;
        case CRYPTO_ENGINE_OPENSSL:
            self.chainGetter = [CKOpenSSLCertificateChainGetter new];
            break;
        default:
            PError(@"Unknown crypto engine %u", (unsigned int)self.options.cryptoEngine);
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:unexpectedError:)]) {
                [self.delegate getter:self unexpectedError:[NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKGetter" code:200 userInfo:@{NSLocalizedDescriptionKey: @"Unknown crypto engine"}]];
            }
            return;
    }

    self.chainGetter.delegate = self;
    self.chainGetter.tag = CKGetterTaskTagChain;
    self.chainGetter.options = self.options;

    self.serverInfoGetter = [CKServerInfoGetter new];
    self.serverInfoGetter.delegate = self;
    self.serverInfoGetter.options = self.options;
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
