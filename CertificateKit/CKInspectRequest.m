//
//  CKInspectRequest.m
//
//  LGPLv3
//
//  Copyright (c) 2023 Ian Spence
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

#import "CKInspectRequest.h"
#import "CKNetworkFrameworkInspector.h"
#import "CKOpenSSLInspector.h"
#import "CKResolver.h"
#import "CKInspector.h"
#import "CKInspectParameters+Private.h"

@interface CKInspectRequest ()

@property (strong, nonatomic) NSObject<CKInspector> * inspector;
@property (strong, nonatomic, readwrite) CKInspectParameters * parameters;
@property (strong, nonatomic) CKInspectParameters * internalParameters;

@end

@implementation CKInspectRequest

+ (CKInspectRequest *) requestWithParameters:(CKInspectParameters *)parameters {
    CKInspectRequest * request = [CKInspectRequest new];
    request.parameters = parameters;
    request.internalParameters = [parameters copy];
    return request;
}

- (void) executeOn:(dispatch_queue_t)queue completed:(void (^)(CKInspectResponse *, NSError *))completed {
    bool __block executeCompleted = false;

    dispatch_async(queue, ^{
        PDebug(@"Executing inspection request on queue %s: %@", dispatch_queue_get_label(queue), self.internalParameters.description);

        if (self.internalParameters.ipAddress == nil || self.internalParameters.ipAddress.length == 0) {
            CKResolvedAddress * resovledAddress;
            NSError * resolveError;
            switch (self.internalParameters.ipVersion) {
                case CKIPAddressVersionUnspecified:
                    resovledAddress = [[CKResolver sharedResolver] getAddressFromDomain:self.internalParameters.hostAddress withError:&resolveError];
                    break;
                case CKIPAddressVersion4:
                    resovledAddress = [[CKResolver sharedResolver] getIPv4AddressFromDomain:self.internalParameters.hostAddress withError:&resolveError];
                    break;
                case CKIPAddressVersion6:
                    resovledAddress = [[CKResolver sharedResolver] getIPv6AddressFromDomain:self.internalParameters.hostAddress withError:&resolveError];
                    break;
            }
            if (resolveError != nil) {
                PError(@"Error resolving query URL: %@", resolveError.localizedDescription);
                executeCompleted = true;
                completed(nil, resolveError);
                return;
            }
            self.internalParameters.ipAddress = resovledAddress.address;
            self.internalParameters.resolvedAddress = resovledAddress;
        }

        switch (self.internalParameters.cryptoEngine) {
            case CKNetworkEngineNetworkFramework:
                self.inspector = [CKNetworkFrameworkInspector new];
                break;
            case CKNetworkEngineOpenSSL:
                self.inspector = [CKOpenSSLInspector new];
                break;
            default:
                PError(@"Unknown crypto engine %u", (unsigned int)self.internalParameters.cryptoEngine);
                executeCompleted = true;
                completed(nil, [NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKGetter" code:200 userInfo:@{NSLocalizedDescriptionKey: @"Unknown crypto engine"}]);
                return;
        }

        [self.inspector executeWithParameters:self.internalParameters completed:^(CKInspectResponse * response, NSError * error) {
            executeCompleted = true;
            completed(response, error);
        }];
    });

    if (self.parameters.timeout > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.parameters.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (executeCompleted) {
                return;
            }
            PError(@"Timed out after %i seconds", (int)self.parameters.timeout);
            dispatch_suspend(queue);
            completed(nil, MAKE_ERROR(1, @"Timed out"));
            return;
        });
    }
}

@end
