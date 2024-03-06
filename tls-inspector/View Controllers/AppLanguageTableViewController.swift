import UIKit

class AppLanguageTableViewController: UITableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SupportedLanguages.allCases.count+1
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return lang(key: "app_language_footer")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "system")
            cell.textLabel?.text = lang(key: "Use system language")
            if UserOptions.appLanguage == nil {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
        let idx = indexPath.row-1
        let language = SupportedLanguages.allCases[idx]
        let cell = UITableViewCell(style: .default, reuseIdentifier: language.rawValue)
        cell.textLabel?.text = lang(key: "Language::\(language.rawValue)")
        if UserOptions.appLanguage == language {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            UserOptions.appLanguage = nil
        } else {
            let idx = indexPath.row-1
            let language = SupportedLanguages.allCases[idx]
            UserOptions.appLanguage = language
        }

        UIHelper(self).presentAlert(title: lang(key: "Language Updated"), body: lang(key: "You must fully close and reopen the app for the new language to take effect.")) {
            self.tableView.reloadData()
        }
    }
}
