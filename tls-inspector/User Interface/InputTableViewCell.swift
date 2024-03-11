import UIKit

class InputTableViewCell: TableViewCell {
    var titleLabel: UILabel!
    var textField: UITextField!
    var valueDidChange: ((String) -> Void)!

    static func Cell(title: String, configureInput: (UITextField) -> Void, valueDidChange: @escaping (String) -> Void) -> InputTableViewCell {
        let cell = InputTableViewCell(UITableViewCell(style: .default, reuseIdentifier: ""))
        cell.cell.frame = CGRect(x: 0, y: 0, width: 375, height: 70)

        cell.titleLabel = UILabel(frame: CGRect(x: 17, y: 11, width: 36, height: 17))
        cell.titleLabel.textAlignment = .left
        cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        cell.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.titleLabel.text = title
        cell.titleLabel.textColor = UIColor.gray
        cell.cell.contentView.addSubview(cell.titleLabel)
        cell.titleLabel.leadingAnchor.constraint(equalTo: cell.cell.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        cell.titleLabel.topAnchor.constraint(equalTo: cell.cell.contentView.layoutMarginsGuide.topAnchor).isActive = true

        cell.textField = UITextField(frame: CGRect(x: 17, y: 36, width: 343, height: 21))
        cell.textField.font = UIFont.preferredFont(forTextStyle: .body)
        cell.valueDidChange = valueDidChange
        configureInput(cell.textField)
        cell.textField.addTarget(cell, action: #selector(cell.inputValueChanged(sender:)), for: .editingChanged)

        cell.cell.contentView.addSubview(cell.textField)
        cell.textField.leadingAnchor.constraint(equalTo: cell.cell.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        cell.textField.trailingAnchor.constraint(equalTo: cell.cell.contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        cell.textField.bottomAnchor.constraint(equalTo: cell.cell.contentView.layoutMarginsGuide.bottomAnchor).isActive = true

        let verticalSpacing = NSLayoutConstraint(item: cell.textField as Any,
                                                 attribute: .top,
                                                 relatedBy: .equal,
                                                 toItem: cell.titleLabel,
                                                 attribute: .bottom,
                                                 multiplier: 1.0,
                                                 constant: 8.0)
        cell.cell.contentView.addConstraint(verticalSpacing)
        cell.titleLabel.setNeedsLayout()
        cell.textField.setNeedsLayout()
        cell.cell.setNeedsLayout()
        cell.cell.selectionStyle = .none

        cell.cell.accessibilityLabel = cell.titleLabel.text

        return cell
    }

    @objc func inputValueChanged(sender: UITextField) {
        self.valueDidChange(sender.text ?? "")
    }
}
