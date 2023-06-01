import UIKit

class AppIconTableViewController: UITableViewController {

    let iconNames = [ "Default", "Light", "Dark", "Pride", "Trans" ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // FIXME(ian): I fought for like an hour to try and get the footer text to not be cut off from the cells, and I give up. UITableView is the worst. I hate it.
        // Insert a blank section just to space it out. It looks dumb but better than being cut off.
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.iconNames.count
        }
        return 0
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
        if section == 0 {
            return nil
        }
        return lang(key: "AppIconFooter")
    }
}
