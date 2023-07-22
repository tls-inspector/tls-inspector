//
//  CKInspectResponse.h
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

#import <Foundation/Foundation.h>
#import "CKCertificateChain.h"
#import "CKHTTPServerInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CKInspectResponse : NSObject

@property (strong, nonatomic, nonnull, readonly) CKCertificateChain * certificateChain;
@property (strong, nonatomic, nullable, readonly) CKHTTPServerInfo * httpServer;
@property (nonatomic) double elapsed;

+ (CKInspectResponse * _Nonnull) responseWithCertificateChain:(CKCertificateChain * _Nonnull)certificateChain;

@end

NS_ASSUME_NONNULL_END
