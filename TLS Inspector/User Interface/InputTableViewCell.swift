import UIKit

class InputTableViewCell: UITableViewCell {
    var titleLabel: UILabel!
    var textField: UITextField!
    var valueDidChange: ((String) -> Void)!

    static func Cell(title: String, configureInput: (UITextField) -> Void, valueDidChange: @escaping (String) -> Void) -> InputTableViewCell {
        let cell = InputTableViewCell(style: .default, reuseIdentifier: "")
        cell.frame = CGRect(x: 0, y: 0, width: 375, height: 70)

        cell.titleLabel = UILabel(frame: CGRect(x: 17, y: 11, width: 36, height: 17))
        cell.titleLabel.textAlignment = .left
        cell.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        cell.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.titleLabel.text = title
        cell.titleLabel.textColor = UIColor.gray
        cell.contentView.addSubview(cell.titleLabel)
        cell.titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        cell.titleLabel.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor).isActive = true

        cell.textField = UITextField(frame: CGRect(x: 17, y: 36, width: 343, height: 21))
        cell.valueDidChange = valueDidChange
        configureInput(cell.textField)
        cell.textField.addTarget(cell, action: #selector(cell.inputValueChanged(sender:)), for: .editingChanged)

        cell.contentView.addSubview(cell.textField)
        cell.textField.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        cell.textField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        cell.textField.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor).isActive = true

        let verticalSpacing = NSLayoutConstraint(item: cell.textField as Any,
                                                 attribute: .top,
                                                 relatedBy: .equal,
                                                 toItem: cell.titleLabel,
                                                 attribute: .bottom,
                                                 multiplier: 1.0,
                                                 constant: 8.0)
        cell.contentView.addConstraint(verticalSpacing)
        cell.titleLabel.setNeedsLayout()
        cell.textField.setNeedsLayout()
        cell.setNeedsLayout()
        cell.selectionStyle = .none

        cell.accessibilityLabel = cell.titleLabel.text

        return cell
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc func inputValueChanged(sender: UITextField) {
        self.valueDidChange(sender.text ?? "")
    }
}
