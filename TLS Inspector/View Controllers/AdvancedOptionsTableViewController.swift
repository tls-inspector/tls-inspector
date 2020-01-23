import UIKit

class AdvancedOptionsTableViewController: UITableViewController {
    var segmentControl: UISegmentedControl?

    override func viewDidLoad() {
        super.viewDidLoad()

        if !UserOptions.advancedSettingsNagDismissed {
            UIHelper(self).presentAlert(title: lang(key: "Warning"), body: lang(key: "advanced_settings_nag"), dismissed: nil)
            UserOptions.advancedSettingsNagDismissed = true
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return UserOptions.useOpenSSL ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
            cell = tableView.dequeueReusableCell(withIdentifier: "Segment", for: indexPath)
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = lang(key: "Crypto Engine")
            }
            self.segmentControl = cell.viewWithTag(2) as? UISegmentedControl
            self.segmentControl?.setTitle("iOS", forSegmentAt: 0)
            self.segmentControl?.setTitle("OpenSSL", forSegmentAt: 1)
            self.segmentControl?.selectedSegmentIndex = UserOptions.useOpenSSL ? 1 : 0
            self.segmentControl?.addTarget(self, action: #selector(self.changeCryptoEngine(sender:)), for: .valueChanged)
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

    @objc func changeCryptoEngine(sender: UISegmentedControl) {
        UserOptions.useOpenSSL = sender.selectedSegmentIndex == 1

        if sender.selectedSegmentIndex == 1 {
            self.tableView.insertSections(IndexSet(arrayLiteral: 1), with: .fade)
        } else {
            self.tableView.deleteSections(IndexSet(arrayLiteral: 1), with: .fade)
        }
    }

    @objc func changeCiphers(_ sender: UITextField) {
        UserOptions.preferredCiphers = sender.text ?? ""
    }
}
