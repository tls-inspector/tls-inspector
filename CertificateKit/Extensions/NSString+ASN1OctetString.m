#import "NSString+ASN1OctetString.h"

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
