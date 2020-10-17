import UIKit

class AdvancedOptionsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if !UserOptions.advancedSettingsNagDismissed {
            UIHelper(self).presentAlert(title: lang(key: "Warning"), body: lang(key: "advanced_settings_nag"), dismissed: nil)
            UserOptions.advancedSettingsNagDismissed = true
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return UserOptions.cryptoEngine == .OpenSSL ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return CryptoEngine.allValues().count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return lang(key: "Crypto Engine")
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return lang(key: "crypto_engine_footer")
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
            let type = CryptoEngine.allValues()[indexPath.row]

            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = lang(key: "crypto_engine::" + type.rawValue)
            }

            if let iconLabel = cell.viewWithTag(2) as? UILabel {
                if UserOptions.cryptoEngine == type {
                    iconLabel.font = FAIcon.FACheckCircleSolid.font(size: 20.0)
                    iconLabel.text = FAIcon.FACheckCircleSolid.string()
                    iconLabel.textColor = UIColor.systemBlue
                } else {
                    iconLabel.font = FAIcon.FACircleRegular.font(size: 20.0)
                    iconLabel.text = FAIcon.FACircleRegular.string()
                    iconLabel.textColor = UIColor.gray
                }
            }
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Input", for: indexPath)
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = lang(key: "Ciphers")
            }
            if let input = cell.viewWithTag(2) as? UITextField {
                input.placeholder = "HIGH:!aNULL:!MD5:!RC4"
                input.text = UserOptions.preferredCiphers
                input.addTarget(self, action: #selector(changeCiphers(_:)), for: .editingChanged)
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let before = UserOptions.cryptoEngine
            let after = CryptoEngine.allValues()[indexPath.row]
            if before == after {
                self.tableView.reloadSections([0], with: .automatic)
                return
            }
            UserOptions.cryptoEngine = after

            if UserOptions.cryptoEngine == .OpenSSL {
                self.tableView.insertSections([1], with: .fade)
            } else if before == .OpenSSL {
                self.tableView.deleteSections([1], with: .fade)
            }
            self.tableView.reloadSections([0], with: .automatic)
        }
    }

    @objc func changeCiphers(_ sender: UITextField) {
        UserOptions.preferredCiphers = sender.text ?? ""
    }
}
