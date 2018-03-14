#import "CertificateTableRowSection.h"

@implementation CertificateTableRowSection

+ (CertificateTableRowSection *) sectionWithTitle:(NSString *)title {
    CertificateTableRowSection * section = [CertificateTableRowSection new];
    section.title = title;
    return section;
}

@end
