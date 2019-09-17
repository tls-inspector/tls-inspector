#import "TableRowSection.h"

@implementation TableRowSection

+ (TableRowSection *) sectionWithTitle:(NSString *)title {
    TableRowSection * section = [TableRowSection new];
    section.title = title;
    return section;
}

@end
