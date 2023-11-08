//
//  NSString+ASN1OctetString.m
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

#import <CertificateKit/NSString+ASN1OctetString.h>

@implementation NSString (ASN1_OCTETSTRING)

+ (NSString *) asn1OctetStringToHexString:(ASN1_OCTET_STRING *)str {
    unsigned char * buffer = str->data;
    int len = str->length;

    char *tmp, *q;
    const unsigned char *p;
    int i;
    static const char hexdig[] = "0123456789ABCDEF";
    if (!buffer || !len)
        return nil;
    if (!(tmp = malloc(len * 3 + 1))) {
        return nil;
    }
    q = tmp;
    for (i = 0, p = buffer; i < len; i++, p++) {
        *q++ = hexdig[(*p >> 4) & 0xf];
        *q++ = hexdig[*p & 0xf];
        *q++ = ':';
    }
    q[-1] = 0;

    NSString * string = [[NSString alloc] initWithUTF8String:tmp];
    free(tmp);
    return string;
}

@end
