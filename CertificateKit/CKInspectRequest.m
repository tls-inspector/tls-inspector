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
#import "CKSecureTransportInspector.h"
#import "CKOpenSSLInspector.h"
#import "CKResolver.h"
#import "CKInspector.h"
#import "CKInspectParameters+Private.h"

@interface CKInspectRequest ()

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
    dispatch_async(queue, ^{

        if (self.internalParameters.ipAddress == nil || self.internalParameters.ipAddress.length == 0) {
            CKResolvedAddress * resovledAddress;
            NSError * resolveError;
            switch (self.internalParameters.ipVersion) {
                case IP_VERSION_AUTOMATIC:
                    resovledAddress = [[CKResolver sharedResolver] getAddressFromDomain:self.internalParameters.hostAddress withError:&resolveError];
                    break;
                case IP_VERSION_IPV4:
                    resovledAddress = [[CKResolver sharedResolver] getIPv4AddressFromDomain:self.internalParameters.hostAddress withError:&resolveError];
                    break;
                case IP_VERSION_IPV6:
                    resovledAddress = [[CKResolver sharedResolver] getIPv6AddressFromDomain:self.internalParameters.hostAddress withError:&resolveError];
                    break;
            }
            if (resolveError != nil) {
                PError(@"Error resolving query URL: %@", resolveError.localizedDescription);
                completed(nil, resolveError);
                return;
            }
            self.internalParameters.ipAddress = resovledAddress.address;
            self.internalParameters.resolvedAddress = resovledAddress;
        }

        PDebug(@"Starting getter for: %@", self.internalParameters.description);

        NSObject<CKInspector> * inspector;

        switch (self.internalParameters.cryptoEngine) {
            case CRYPTO_ENGINE_NETWORK_FRAMEWORK:
                inspector = [CKNetworkFrameworkInspector new];
                break;
            case CRYPTO_ENGINE_SECURE_TRANSPORT:
                inspector = [CKSecureTransportInspector new];
                break;
            case CRYPTO_ENGINE_OPENSSL:
                inspector = [CKOpenSSLInspector new];
                break;
            default:
                PError(@"Unknown crypto engine %u", (unsigned int)self.internalParameters.cryptoEngine);
                completed(nil, [NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKGetter" code:200 userInfo:@{NSLocalizedDescriptionKey: @"Unknown crypto engine"}]);
                return;
        }

        [inspector executeWithParameters:self.internalParameters completed:^(CKInspectResponse * response, NSError * error) {
            completed(response, error);
        }];
    });
}

@end
