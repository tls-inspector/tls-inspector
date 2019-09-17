#import <Foundation/Foundation.h>

@interface TableRowItem : NSObject

typedef NS_ENUM(NSUInteger, CertificateTableRowItemStyle) {
    CertificateTableRowItemStyleBasic,
    CertificateTableRowItemStyleBasicDisclosure,
    CertificateTableRowItemStyleBasicValue,
    CertificateTableRowItemStyleExpandedValue,
    CertificateTableRowItemStyleFixedValue,
};

@property (strong, nonatomic, nonnull) NSString * title;
@property (strong, nonatomic, nonnull) NSString * value;
@property (nonatomic) CertificateTableRowItemStyle style;

+ (TableRowItem * _Nonnull) itemWithTitle:(NSString * _Nullable)title value:(NSString * _Nullable)value style:(CertificateTableRowItemStyle)style;
- (UITableViewCell * _Nonnull) cellForRowItem;

@end
