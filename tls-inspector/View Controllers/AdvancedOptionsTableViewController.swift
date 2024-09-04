import UIKit
import CertificateKit

class AdvancedOptionsTableViewController: UITableViewController, UITextFieldDelegate {
    private enum SectionTags: Int {
        case Engine = 0
        case EngineOptions = 1
        case Logs = 2
        case RootCA = 3
        case Reset = 4
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

    func engineCell(engine: CryptoEngine) -> TableViewCell? {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: nil)

        cell.textLabel?.text = lang(key: "CKNetworkEngine::" + engine.rawValue)
        cell.accessibilityLabel = engine.rawValue
        if UserOptions.cryptoEngine == engine {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.tag = engine.intValue()
        return TableViewCell(cell)
    }

    func buildEngineSection() -> TableViewSection {
        let engineSection = TableViewSection()
        engineSection.title = lang(key: "Network Engine")
        engineSection.footer = lang(key: "crypto_engine_footer")
        engineSection.tag = SectionTags.Engine.rawValue

        engineSection.cells.maybeAppend(engineCell(engine: .NetworkFramework))
        engineSection.cells.maybeAppend(engineCell(engine: .OpenSSL))

        return engineSection
    }

    func buildEngineOptionsSection() -> TableViewSection {
        let engineOptionsSection = TableViewSection()
        engineOptionsSection.title = lang(key: "Engine Settings")
        engineOptionsSection.tag = SectionTags.EngineOptions.rawValue
        engineOptionsSection.cells.maybeAppend(buildCiphersCell())
        engineOptionsSection.cells.append(buildIPVersionCell())
        engineOptionsSection.cells.maybeAppend(buildTimeoutCell())
        return engineOptionsSection
    }

    func buildRootCASection() -> TableViewSection {
        let rootCASection = TableViewSection()
        rootCASection.tag = SectionTags.RootCA.rawValue

        let cell = UITableViewCell()
        cell.textLabel?.text = lang(key: "Root CA Certificates")
        cell.accessoryType = .disclosureIndicator
        rootCASection.cells.append(TableViewCell(cell))

        return rootCASection
    }

    func buildResetSection() -> TableViewSection {
        let resetSection = TableViewSection()
        resetSection.tag = SectionTags.Reset.rawValue

        let cell = UITableViewCell()
        cell.textLabel?.text = lang(key: "Reset to Default Settings")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = UIColor.systemRed
        resetSection.cells.append(TableViewCell(cell))

        return resetSection
    }

    func buildCiphersCell() -> TableViewCell? {
        if UserOptions.cryptoEngine != .OpenSSL {
            return nil
        }

        let cipherCell = TableViewCell(UITableViewCell())
        cipherCell.cell.textLabel?.text = lang(key: "Ciphers")

        let cipherText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        cipherText.textAlignment = .right
        cipherText.font = UIFont(name: "Menlo", size: UIFont.systemFontSize)
        cipherText.text = UserOptions.preferredCiphers
        cipherText.autocorrectionType = .no
        cipherText.autocapitalizationType = .none
        cipherText.smartQuotesType = .no
        cipherText.smartDashesType = .no
        cipherText.returnKeyType = .done
        cipherText.removeTarget(self, action: #selector(changeCiphers(_:)), for: .editingChanged)
        cipherText.addTarget(self, action: #selector(changeCiphers(_:)), for: .editingChanged)
        cipherText.delegate = self
        cipherText.sizeToFit()

        cipherCell.cell.accessoryView = cipherText
        cipherCell.cell.selectionStyle = .none

        return cipherCell
    }

    func buildIPVersionCell() -> TableViewCell {
        let ipVersionCell = TableViewCell(UITableViewCell())
        ipVersionCell.cell.textLabel?.text = lang(key: "Use IP Version")
        ipVersionCell.cell.selectionStyle = .none

        let segmentControl = UISegmentedControl(items: [
            lang(key: "Auto"),
            "IPv4",
            "IPv6"
        ])
        ipVersionCell.cell.accessoryView = segmentControl
        switch UserOptions.ipVersion {
        case .Automatic:
            segmentControl.selectedSegmentIndex = 0
        case .IPv4:
            segmentControl.selectedSegmentIndex = 1
        case .IPv6:
            segmentControl.selectedSegmentIndex = 2
        }
        segmentControl.removeTarget(self, action: #selector(changeVersion(_:)), for: .valueChanged)
        segmentControl.addTarget(self, action: #selector(changeVersion(_:)), for: .valueChanged)

        return ipVersionCell
    }

    func buildTimeoutCell() -> TableViewCell? {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "LabelInput") else {
            return nil
        }
        guard let label = cell.viewWithTag(1) as? UILabel else {
            return nil
        }
        guard let input = cell.viewWithTag(2) as? UITextField else {
            return nil
        }
        guard let accessoryLabel = cell.viewWithTag(3) as? UILabel else {
            return nil
        }


        cell.selectionStyle = .none
        label.text = lang(key: "Timeout")
        accessoryLabel.text = lang(key: "Seconds")

        input.textAlignment = .right
        input.font = UIFont.preferredFont(forTextStyle: .body)
        input.text = "\(UserOptions.inspectTimeout)"
        input.placeholder = "..."
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        input.keyboardType = .numberPad
        input.smartQuotesType = .no
        input.smartDashesType = .no
        input.returnKeyType = .done
        input.removeTarget(self, action: #selector(changeTimeout(_:)), for: .editingChanged)
        input.addTarget(self, action: #selector(changeTimeout(_:)), for: .editingChanged)
        input.delegate = self

        return TableViewCell(cell)
    }

    func buildLogsSection() -> TableViewSection {
        let loggingSection = TableViewSection()
        loggingSection.title = lang(key: "Logging")
        loggingSection.footer = lang(key: "verbose_logging_footer")
        loggingSection.tag = SectionTags.Logs.rawValue

        loggingSection.cells.append(SwitchTableViewCell(labelText: lang(key: "Enable Verbose Logging"), defaultChecked: UserOptions.verboseLogging, didChange: { checked in
            if !UserOptions.verboseLogging && checked {
                UserOptions.inspectionsWithVerboseLogging = 0
            }
            UserOptions.verboseLogging = checked
        }))

        if #available(iOS 15, *) {
            if let submitLogsCell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Icon")) {
                guard let textLabel = submitLogsCell.cell.viewWithTag(1) as? UILabel else {
                    return loggingSection
                }

                guard let iconLabel = submitLogsCell.cell.viewWithTag(2) as? UILabel else {
                    return loggingSection
                }

                textLabel.text = lang(key: "Submit Logs")
                iconLabel.font = FAIcon.FABugSolid.font(size: iconLabel.font.pointSize)
                iconLabel.textColor = UIColor.red
                iconLabel.text = FAIcon.FABugSolid.string()

                loggingSection.cells.append(submitLogsCell)
            }
        }

        return loggingSection
    }

    func buildTable() {
        self.sections = [
            self.buildEngineSection(),
            self.buildEngineOptionsSection(),
            self.buildLogsSection(),
            self.buildRootCASection(),
            self.buildResetSection()
        ]
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
        return self.sections[indexPath.section].cells[indexPath.row].cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = self.sections[indexPath.section].tag

        if tag == SectionTags.Engine.rawValue {
            self.didTapEngineCell(indexPath: indexPath)
        } else if tag == SectionTags.Logs.rawValue && indexPath.row == 1 {
            self.didTapSubmitLogs(indexPath: indexPath)
        } else if tag == SectionTags.RootCA.rawValue {
            self.performSegue(withIdentifier: "RootCACertificates", sender: self)
        } else if tag == SectionTags.Reset.rawValue {
            UserOptions.reset()
            _ = navigationController?.popViewController(animated: true)
        }
    }

    func didTapEngineCell(indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        let before = UserOptions.cryptoEngine
        guard let after = CryptoEngine.from(int: cell.tag) else { return }
        if before == after {
            return
        }

        UserOptions.cryptoEngine = after
        self.buildTable()
        self.tableView.beginUpdates()
        self.tableView.reloadSections([SectionTags.Engine.rawValue], with: .none)
        self.tableView.reloadSections([SectionTags.EngineOptions.rawValue], with: .fade)
        self.tableView.endUpdates()
        NotificationCenter.default.post(name: CHANGE_CRYPTO_NOTIFICATION, object: nil)
    }

    func didTapSubmitLogs(indexPath: IndexPath) {
        if UserOptions.verboseLogging && UserOptions.inspectionsWithVerboseLogging == 0 {
            UIHelper(self).presentAlert(title: lang(key: "Verbose Logging Enabled"),
                                        body: lang(key: "You must inspect at least one site with verbose logging enabled before you can submit logs."),
                                        dismissed: nil)
            return
        }
        ContactTableViewController.show(self) { (support) in
            AppLinks.current.showEmailCompose(viewController: self, object: support, includeLogs: true, dismissed: nil)
        }
    }

    @objc func changeCiphers(_ sender: UITextField) {
        UserOptions.preferredCiphers = sender.text ?? ""
    }

    @objc func changeTimeout(_ sender: UITextField) {
        guard let timeout = Int(sender.text ?? "") else {
            return
        }
        if timeout < 0 {
            return
        }
        UserOptions.inspectTimeout = timeout
    }

    @objc func changeVersion(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UserOptions.ipVersion = .Automatic
        } else if sender.selectedSegmentIndex == 1 {
            UserOptions.ipVersion = .IPv4
        } else if sender.selectedSegmentIndex == 2 {
            UserOptions.ipVersion = .IPv6
        }
    }

    @objc func toggleDebugMode(_ sender: UISwitch) {
        if !UserOptions.verboseLogging && sender.isOn {
            UserOptions.inspectionsWithVerboseLogging = 0
        }
        UserOptions.verboseLogging = sender.isOn
    }
}
