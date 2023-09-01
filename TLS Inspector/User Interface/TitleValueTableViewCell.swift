import UIKit

class TitleValueTableViewCell: TableViewCell {
    var titleLabel: UILabel!
    var valueLabel: UILabel!

    static func Cell(title: String, value: String, useFixedWidthFont: Bool) -> TitleValueTableViewCell {
        let cell = TitleValueTableViewCell(UITableViewCell(style: .default, reuseIdentifier: ""))
        cell.cell.frame = CGRect(x: 0, y: 0, width: 375, height: 70)

        cell.titleLabel = UILabel(frame: CGRect(x: 17, y: 11, width: 36, height: 17))
        cell.titleLabel.textAlignment = .left
        cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        cell.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.titleLabel.text = title
        cell.titleLabel.textColor = UIColor.gray
        cell.cell.addSubview(cell.titleLabel)
        cell.titleLabel.leadingAnchor.constraint(equalTo: cell.cell.layoutMarginsGuide.leadingAnchor).isActive = true
        cell.titleLabel.topAnchor.constraint(equalTo: cell.cell.layoutMarginsGuide.topAnchor).isActive = true

        cell.valueLabel = UILabel(frame: CGRect(x: 17, y: 36, width: 343, height: 21))
        cell.valueLabel.textAlignment = .left
        cell.valueLabel.numberOfLines = 0
        cell.valueLabel.lineBreakMode = .byWordWrapping
        cell.valueLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.valueLabel.text = value
        if useFixedWidthFont {
            guard let customFont = UIFont(name: "Menlo", size: UIFont.systemFontSize) else {
                fatalError("Failed to load custom font name")
            }
            cell.valueLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: customFont)
            cell.valueLabel.adjustsFontForContentSizeCategory = true
        } else {
            cell.valueLabel.font = UIFont.preferredFont(forTextStyle: .body)
        }
        cell.cell.addSubview(cell.valueLabel)
        cell.valueLabel.leadingAnchor.constraint(equalTo: cell.cell.layoutMarginsGuide.leadingAnchor).isActive = true
        cell.valueLabel.trailingAnchor.constraint(equalTo: cell.cell.layoutMarginsGuide.trailingAnchor).isActive = true
        cell.valueLabel.bottomAnchor.constraint(equalTo: cell.cell.layoutMarginsGuide.bottomAnchor).isActive = true

        let verticalSpacing = NSLayoutConstraint(item: cell.valueLabel as Any,
                                                 attribute: .top,
                                                 relatedBy: .equal,
                                                 toItem: cell.titleLabel,
                                                 attribute: .bottom,
                                                 multiplier: 1.0,
                                                 constant: 8.0)
        cell.cell.addConstraint(verticalSpacing)
        cell.titleLabel.setNeedsLayout()
        cell.valueLabel.setNeedsLayout()
        cell.cell.setNeedsLayout()
        cell.cell.selectionStyle = .none

        cell.shouldShowMenu = { (_: UITableView, _: IndexPath) -> Bool in
            return true
        }
        cell.canPerformAction = { (tableView: UITableView, selector: Selector, _: IndexPath, _: Any?) -> Bool in
            return selector == #selector(tableView.copy(_:))
        }
        cell.performAction = { (tableView: UITableView, selector: Selector, _: IndexPath, _: Any?) -> Void in
            if selector == #selector(tableView.copy(_:)) {
                UIPasteboard.general.string = value
            }
        }

        return cell
    }

    static func Cell(title: String, value: String) -> TitleValueTableViewCell {
        return TitleValueTableViewCell.Cell(title: title, value: value, useFixedWidthFont: false)
    }
}
