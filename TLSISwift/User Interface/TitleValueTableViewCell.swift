import UIKit

class TitleValueTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var valueLabel: UILabel!
    
    static func Cell(title: String, value: String, useFixedWidthFont: Bool) -> TitleValueTableViewCell {
        let cell = TitleValueTableViewCell(style: .default, reuseIdentifier: "")
        cell.frame = CGRect(x: 0, y: 0, width: 375, height: 70)

        cell.titleLabel = UILabel(frame: CGRect(x: 17, y: 11, width: 36, height: 17))
        cell.titleLabel.textAlignment = .left
        cell.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        cell.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.titleLabel.text = title
        cell.titleLabel.textColor = UIColor.darkGray
        cell.addSubview(cell.titleLabel)
        let titleLabelViews = [
            "title": cell.titleLabel,
        ]
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[title]",
                                           options: [],
                                           metrics: nil,
                                           views: titleLabelViews as [String : Any])
        )
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[title]",
                                           options: [],
                                           metrics: nil,
                                           views: titleLabelViews as [String : Any])
        )
        
        cell.valueLabel = UILabel(frame: CGRect(x: 17, y: 36, width: 343, height: 21))
        cell.valueLabel.textAlignment = .left
        cell.valueLabel.numberOfLines = 0
        cell.valueLabel.lineBreakMode = .byWordWrapping
        cell.valueLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.valueLabel.text = value
        if useFixedWidthFont {
            cell.valueLabel.font = UIFont(name: "Menlo", size: 14.0)
        }
        cell.addSubview(cell.valueLabel)
        let valueLabelViews = [
            "value": cell.valueLabel,
            "title": cell.titleLabel,
        ]
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[value]-16-|",
                                           options: [],
                                           metrics: nil,
                                           views: valueLabelViews as [String : Any])
        )
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:[title]-8-[value]-8-|",
                                           options: [],
                                           metrics: nil,
                                           views: valueLabelViews as [String : Any])
        )
        
        cell.titleLabel.setNeedsLayout()
        cell.valueLabel.setNeedsLayout()
        cell.setNeedsLayout()
        cell.selectionStyle = .none
        return cell
    }
    
    static func Cell(title: String, value: String) -> TitleValueTableViewCell {
        return TitleValueTableViewCell.Cell(title: title, value: value, useFixedWidthFont: false)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
