import UIKit

class AdvancedOptionsTableViewController: UITableViewController {
    private enum SectionTags: Int {
        case Engine = 1
        case OpenSSL = 2
        case IPVersion = 3
    }

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
        engineSection.tag = SectionTags.Engine.rawValue

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
        opensslSection.tag = SectionTags.OpenSSL.rawValue

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

    func ipVersionCell(version: IPVersion) -> UITableViewCell? {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: nil)

        switch version {
        case .Automatic:
            cell.textLabel?.text = lang(key: "Automatic")
        case .IPv4:
            cell.textLabel?.text = "IPv4"
        case .IPv6:
            cell.textLabel?.text = "IPv6"
        }

        if UserOptions.ipVersion == version {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.tag = version.intValue()
        return cell
    }

    func buildIPVersionSection() -> TableViewSection? {
        if UserOptions.cryptoEngine == .SecureTransport {
            return nil
        }

        let ipVersionSection = TableViewSection()
        ipVersionSection.title = lang(key: "Use IP Version")
        ipVersionSection.tag = SectionTags.IPVersion.rawValue

        for version in IPVersion.allValues() {
            ipVersionSection.cells.maybeAppend(ipVersionCell(version: version))
        }

        return ipVersionSection
    }

    func buildTable() {
        self.sections = [self.buildEngineSection()]
        self.sections.maybeAppend(buildIPVersionSection())
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
        let tag = self.sections[indexPath.section].tag

        if tag == SectionTags.Engine.rawValue {
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

            // TODO: This is terrible
            var sectionsToInsert: IndexSet = []
            var sectionsToRemove: IndexSet = []
            if after == .SecureTransport && before != .SecureTransport {
                if before == .OpenSSL {
                    sectionsToRemove.insert(1)
                    sectionsToRemove.insert(2)
                } else {
                    sectionsToRemove.insert(1)
                }
            } else if after == .NetworkFramework && before != .NetworkFramework {
                if before == .OpenSSL {
                    sectionsToRemove.insert(2)
                } else if before == .SecureTransport {
                    sectionsToInsert.insert(1)
                }
            } else if after == .OpenSSL && before != .OpenSSL {
                sectionsToInsert.insert(2)
                if before == .SecureTransport {
                    sectionsToInsert.insert(1)
                }
            }

            if sectionsToInsert.count > 0 {
                self.tableView.insertSections(sectionsToInsert, with: .fade)
            }
            if sectionsToRemove.count > 0 {
                self.tableView.deleteSections(sectionsToRemove, with: .fade)
            }
            self.tableView.reloadSections([0], with: .none)
        } else if tag == SectionTags.IPVersion.rawValue {
            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }

            guard let version = IPVersion.from(int: cell.tag) else {
                return
            }

            UserOptions.ipVersion = version
            self.buildTable()
            self.tableView.reloadSections([indexPath.section], with: .none)
        }
    }

    @objc func changeCiphers(_ sender: UITextField) {
        UserOptions.preferredCiphers = sender.text ?? ""
    }
}
