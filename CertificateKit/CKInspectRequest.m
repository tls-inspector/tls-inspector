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
#import "CKNetworkCertificateChainGetter.h"
#import "CKResolver.h"

@interface CKInspectRequest ()

@property (strong, nonatomic, readwrite) CKInspectParameters * parameters;

@end

@implementation CKInspectRequest

+ (CKInspectRequest *) requestWithParameters:(CKInspectParameters *)parameters {
    CKInspectRequest * request = [CKInspectRequest new];
    request.parameters = parameters;
    return request;
}

- (void) executeOn:(dispatch_queue_t)queue completed:(void (^)(CKInspectResponse *, NSError *))completed {
    dispatch_async(queue, ^{
        NSError * resolveError;
        CKResolvedAddress * address = [CKResolver.sharedResolver getAddressFromDomain:self.parameters.hostAddress withError:&resolveError];
        if (resolveError != nil) {
            completed(nil, resolveError);
            return;
        }
        self.parameters.ipAddress = address.address;

        CKNetworkCertificateChainGetter * getter = [CKNetworkCertificateChainGetter new];
        [getter executeWithParameters:[CKGetterParameters fromInspectParameters:self.parameters] completed:^(CKInspectResponse * response, NSError * error) {
            completed(response, error);
        }];
    });
}

@end