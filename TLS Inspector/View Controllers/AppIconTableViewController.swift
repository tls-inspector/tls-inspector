import UIKit

class AppIconTableViewController: UITableViewController {
    let iconNames = [ "Default", "Light", "Dark", "Pride", "Trans" ]

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.iconNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath)
        let iconName = self.iconNames[indexPath.row]

        guard let image = UIImage(named: "Icon\(iconName)") else {
            return cell
        }

        guard let imageView = cell.viewWithTag(2) as? UIImageView else {
            return cell
        }

        guard let label = cell.viewWithTag(1) as? UILabel else {
            return cell
        }

        imageView.image = image
        label.text = lang(key: "AppIcon::\(iconName)")

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let iconName = self.iconNames[indexPath.row]

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

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return lang(key: "AppIconFooter")
    }
}
