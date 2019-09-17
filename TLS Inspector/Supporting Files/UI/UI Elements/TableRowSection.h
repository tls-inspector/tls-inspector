#import <Foundation/Foundation.h>
#import "TableRowItem.h"

@interface TableRowSection : NSObject

+ (TableRowSection * _Nonnull) sectionWithTitle:(NSString * _Nullable)title;

@property (strong, nonatomic, nullable) NSString * title;
@property (strong, nonatomic, nonnull) NSArray<TableRowItem *> * items;
@property (strong, nonatomic, nullable) NSString * footer;

@end
