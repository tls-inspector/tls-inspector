#import <Foundation/Foundation.h>
#import <openssl/asn1.h>

@interface NSString (ASN1_OCTETSTRING)

+ (NSString *) asn1OctetStringToHexString:(ASN1_OCTET_STRING *)str;

@end
