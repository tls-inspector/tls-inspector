//
//  CKAlternateNameObject.h
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

#import <Foundation/Foundation.h>

@interface CKAlternateNameObject : NSObject

typedef NS_ENUM(NSUInteger, AlternateNameType) {
    AlternateNameTypeDNS,
    AlternateNameTypeOther,
    AlternateNameTypeEmail,
    AlternateNameTypeDirectory,
    AlternateNameTypeIP,
    AlternateNameTypeURI,
};

@property (nonatomic) AlternateNameType type;
@property (strong, nonatomic) NSString * value;

@end
