#import "CertificateTableRowItem.h"
#import "TitleValueTableViewCell.h"

@implementation CertificateTableRowItem

+ (CertificateTableRowItem *) itemWithTitle:(NSString *)title value:(NSString *)value style:(CertificateTableRowItemStyle)style {
    CertificateTableRowItem * item = [CertificateTableRowItem new];

    item.title = title;
    item.value = value;
    item.style = style;

    return item;
}

- (UITableViewCell *) cellForRowItem {
    switch (self.style) {
        case CertificateTableRowItemStyleExpandedValue:
        case CertificateTableRowItemStyleFixedValue: {
            TitleValueTableViewCell * cell = [[TitleValueTableViewCell alloc] initWithTitle:self.title value:self.value];
            if (self.style == CertificateTableRowItemStyleFixedValue) {
                [cell useFixedWidthFont];
            }
            return cell;
        }
        case CertificateTableRowItemStyleBasicValue: {
            UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Row"];
            cell.textLabel.text = self.title;
            cell.detailTextLabel.text = self.value;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = colorForTheme([UIColor darkGrayColor], [UIColor lightGrayColor]);
            cell.detailTextLabel.textColor = themeTextColor;
            return cell;
        }
        case CertificateTableRowItemStyleBasic:
        case CertificateTableRowItemStyleBasicDisclosure: {
            UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Row"];
            cell.textLabel.text = self.title;
            if (self.style == CertificateTableRowItemStyleBasicDisclosure) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.textColor = themeTextColor;
            return cell;
        }
        default:
            break;
    }
}

@end
