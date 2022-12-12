import UIKit
import CertificateKit

class AdvancedOptionsTableViewController: UITableViewController {
    private enum SectionTags: Int {
        case Engine = 0
        case EngineOptions = 1
        case Logs = 2
        case RootCA = 3
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

        cell.textLabel?.text = lang(key: "crypto_engine::" + engine.rawValue)
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
        engineSection.title = lang(key: "Crypto Engine")
        engineSection.footer = lang(key: "crypto_engine_footer")
        engineSection.tag = SectionTags.Engine.rawValue

        engineSection.cells.maybeAppend(engineCell(engine: .NetworkFramework))
        engineSection.cells.maybeAppend(engineCell(engine: .SecureTransport))
        engineSection.cells.maybeAppend(engineCell(engine: .OpenSSL))

        return engineSection
    }

    func buildEngineOptionsSection() -> TableViewSection {
        let engineOptionsSection = TableViewSection()
        engineOptionsSection.title = lang(key: "Engine Settings")
        engineOptionsSection.tag = SectionTags.EngineOptions.rawValue
        engineOptionsSection.cells.maybeAppend(buildCiphersCell())
        engineOptionsSection.cells.maybeAppend(buildIPVersionCell())
        return engineOptionsSection
    }

    func buildRootCASection() -> TableViewSection {
        let rootCASection = TableViewSection()
        rootCASection.tag = SectionTags.RootCA.rawValue

        if let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Basic")) {
            cell.cell.textLabel?.text = lang(key: "Root CA Certificates")
            rootCASection.cells.append(cell)
        }

        return rootCASection
    }

    func buildCiphersCell() -> TableViewCell? {
        if UserOptions.cryptoEngine != .OpenSSL {
            return nil
        }

        guard let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Input")) else {
            LogError("No cell named 'Input' found")
            return nil
        }

        guard let label = cell.cell.viewWithTag(1) as? UILabel else {
            LogError("No label with tag 1 on cell")
            return nil
        }

        guard let input = cell.cell.viewWithTag(2) as? UITextField else {
            LogError("No input with tag 1 on cell")
            return nil
        }

        label.text = lang(key: "Ciphers")
        input.text = UserOptions.preferredCiphers
        input.removeTarget(self, action: #selector(changeCiphers(_:)), for: .editingChanged)
        input.addTarget(self, action: #selector(changeCiphers(_:)), for: .editingChanged)

        return cell
    }

    func buildIPVersionCell() -> TableViewCell? {
        guard let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Segment")) else {
            LogError("No cell named 'Segment' found")
            return nil
        }

        guard let label = cell.cell.viewWithTag(1) as? UILabel else {
            LogError("No label with tag 1 on cell")
            return nil
        }

        guard let segmentControl = cell.cell.viewWithTag(2) as? UISegmentedControl else {
            LogError("No segment control with tag 2 on cell")
            return nil
        }
        segmentControl.setTitle(lang(key: "Auto"), forSegmentAt: 0)
        segmentControl.setTitle("IPv4", forSegmentAt: 1)
        if segmentControl.numberOfSegments == 2 {
            segmentControl.insertSegment(withTitle: "IPv6", at: 2, animated: false)
        } else {
            segmentControl.setTitle("IPv6", forSegmentAt: 2)
        }
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
        label.text = lang(key: "Use IP Version")

        return cell
    }

    func buildLogsSection() -> TableViewSection {
        let loggingSection = TableViewSection()
        loggingSection.title = lang(key: "Logging")
        loggingSection.footer = lang(key: "verbose_logging_footer")
        loggingSection.tag = SectionTags.Logs.rawValue

        if let debugLoggingCell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Switch")) {
            guard let debugLabel = debugLoggingCell.cell.viewWithTag(1) as? UILabel else {
                return loggingSection
            }

            guard let debugSwitch = debugLoggingCell.cell.viewWithTag(2) as? UISwitch else {
                return loggingSection
            }

            debugLabel.text = lang(key: "Enable Debug Logging")
            debugSwitch.isOn = UserOptions.verboseLogging
            debugSwitch.addTarget(self, action: #selector(self.toggleDebugMode(_:)), for: .valueChanged)
            loggingSection.cells.append(debugLoggingCell)
        }

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

        return loggingSection
    }

    func buildTable() {
        self.sections = [
            self.buildEngineSection(),
            self.buildEngineOptionsSection(),
            self.buildLogsSection(),
            self.buildRootCASection()
        ]
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
    }

    func didTapSubmitLogs(indexPath: IndexPath) {
        if UserOptions.verboseLogging && UserOptions.inspectionsWithVerboseLogging == 0 {
            UIHelper(self).presentAlert(title: lang(key: "Debug Logging Enabled"),
                                        body: lang(key: "You must inspect at least one site with debug logging enabled before you can submit logs."),
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
        UserOptions.verboseLogging = sender.isOn
    }
}
