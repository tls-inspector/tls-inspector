import UIKit

class AppIconTableViewController: UITableViewController {
    let generalIcons = [ "Default", "Light", "Dark", "Skew", "Slate" ]
    let specialIcons = [ "Pride", "Trans" ]

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return generalIcons.count
        } else if section == 1 {
            return specialIcons.count
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var iconName = ""
        if indexPath.section == 0 {
            iconName = generalIcons[indexPath.row]
        } else if indexPath.section == 1 {
            iconName = specialIcons[indexPath.row]
        }

        let cell = UITableViewCell()
        cell.textLabel?.text = lang(key: "AppIcon::\(iconName)")

        guard let image = UIImage(named: "Icon\(iconName)") else {
            return cell
        }

        cell.imageView?.image = image
        cell.imageView?.cornerRadius = 15.0

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var iconName = ""
        if indexPath.section == 0 {
            iconName = generalIcons[indexPath.row]
        } else if indexPath.section == 1 {
            iconName = specialIcons[indexPath.row]
        } else {
            return
        }

        if iconName == "Default" {
            UIApplication.shared.setAlternateIconName(nil)
        } else {
            UIApplication.shared.setAlternateIconName("Icon\(iconName)") { error in
                if let err = error {
                    UIHelper(self).presentError(error: err, dismissed: nil)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return lang(key: "General")
        } else if section == 1 {
            return lang(key: "Special")
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        return lang(key: "AppIconFooter")
    }
}
