#import <Foundation/Foundation.h>
#import "CertificateTableRowItem.h"

@interface CertificateTableRowSection : NSObject

+ (CertificateTableRowSection * _Nonnull) sectionWithTitle:(NSString * _Nullable)title;

@property (strong, nonatomic, nullable) NSString * title;
@property (strong, nonatomic, nonnull) NSArray<CertificateTableRowItem *> * items;
@property (strong, nonatomic, nullable) NSString * footer;

@end
