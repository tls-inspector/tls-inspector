import UIKit

/// A table view cell with a label and a switch
class SwitchTableViewCell: TableViewCell {
    private let didChange: ((Bool) -> Void)

    /// Create a new switch table view cell with the given label text, default switch state, and a closure for when the switch is toggled
    init(labelText: String, defaultChecked: Bool, didChange: @escaping ((Bool) -> Void)) {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        if let textLabel = cell.textLabel {
            textLabel.text = labelText
            textLabel.numberOfLines = 0
        }

        let uiSwitch = UISwitch()
        uiSwitch.onTintColor = UIColor.systemBlue
        uiSwitch.setOn(defaultChecked, animated: false)
        cell.accessoryView = uiSwitch
        cell.selectionStyle = .none
        self.didChange = didChange

        super.init(cell)
        uiSwitch.addTarget(self, action: #selector(switchChange), for: .valueChanged)
    }

    @objc func switchChange(sender: UISwitch) {
        self.didChange(sender.isOn)
    }
}
