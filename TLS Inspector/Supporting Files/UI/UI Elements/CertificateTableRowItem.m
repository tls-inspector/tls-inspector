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
                cell.valueLabel.font = [UIFont fontWithName:@"Menlo" size:14.0f];
            }
            return cell;
        }
        case CertificateTableRowItemStyleBasicValue: {
            UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Row"];
            cell.textLabel.text = self.title;
            cell.detailTextLabel.text = self.value;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        case CertificateTableRowItemStyleBasic: {
            UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Row"];
            cell.textLabel.text = self.title;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        default:
            break;
    }
}

@end
