import UIKit

class AdvancedOptionsTableViewController: UITableViewController {
    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if !UserOptions.advancedSettingsNagDismissed {
            UIHelper(self).presentAlert(title: lang(key: "Warning"), body: lang(key: "advanced_settings_nag"), dismissed: nil)
            UserOptions.advancedSettingsNagDismissed = true
        }

        self.buildTable()
    }

    func engineCell(engine: CryptoEngine) -> UITableViewCell? {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: nil)

        cell.textLabel?.text = lang(key: "crypto_engine::" + engine.rawValue)
        if UserOptions.cryptoEngine == engine {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.tag = engine.intValue()
        return cell
    }

    func buildEngineSection() -> TableViewSection {
        let engineSection = TableViewSection()
        engineSection.title = lang(key: "Crypto Engine")
        engineSection.footer = lang(key: "crypto_engine_footer")

        if #available(iOS 12, *) {
            engineSection.cells.maybeAppend(engineCell(engine: .NetworkFramework))
        }
        engineSection.cells.maybeAppend(engineCell(engine: .SecureTransport))
        engineSection.cells.maybeAppend(engineCell(engine: .OpenSSL))

        return engineSection
    }

    func buildOpenSSLSection() -> TableViewSection? {
        if UserOptions.cryptoEngine != .OpenSSL {
            return nil
        }

        let opensslSection = TableViewSection()
        opensslSection.title = lang(key: "OpenSSL Settings")

        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Input") else {
            LogError("No cell named 'Input' found")
            return opensslSection
        }

        guard let label = cell.viewWithTag(1) as? UILabel else {
            LogError("No label with tag 1 on cell")
            return opensslSection
        }

        guard let input = cell.viewWithTag(2) as? UITextField else {
            LogError("No input with tag 1 on cell")
            return opensslSection
        }

        label.text = lang(key: "Ciphers")
        input.text = UserOptions.preferredCiphers
        input.removeTarget(self, action: #selector(changeCiphers(_:)), for: .editingChanged)
        input.addTarget(self, action: #selector(changeCiphers(_:)), for: .editingChanged)

        opensslSection.cells = [cell]
        return opensslSection
    }

    func buildTable() {
        self.sections = [self.buildEngineSection()]
        self.sections.maybeAppend(buildOpenSSLSection())
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }

            let before = UserOptions.cryptoEngine
            guard let after = CryptoEngine.from(int: cell.tag) else {
                return
            }
            if before == after {
                return
            }

            UserOptions.cryptoEngine = after
            self.buildTable()

            if UserOptions.cryptoEngine == .OpenSSL {
                self.tableView.insertSections([1], with: .fade)
            } else if before == .OpenSSL {
                self.tableView.deleteSections([1], with: .fade)
            }
            self.tableView.reloadSections([0], with: .none)
        }
    }

    @objc func changeCiphers(_ sender: UITextField) {
        UserOptions.preferredCiphers = sender.text ?? ""
    }
}
