//
//  CKGetterParameters.m
//
//  LGPLv3
//
//  Copyright (c) 2021 Ian Spence
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

#import "CKGetterParameters.h"

@implementation CKGetterParameters

- (NSString *) description {
    return [NSString stringWithFormat:@"queryURL='%@' ipAddress='%@' queryServerInfo='%@' checkOCSP='%@' checkCRL='%@' cryptoEngine='%i' ipVersion='%i' ciphers='%@'",
            self.queryURL.description,
            self.ipAddress.description,
            self.queryServerInfo ? @"YES" : @"NO",
            self.checkOCSP ? @"YES" : @"NO",
            self.checkCRL ? @"YES" : @"NO",
            self.cryptoEngine,
            self.ipVersion,
            self.ciphers.description];
}

@end
