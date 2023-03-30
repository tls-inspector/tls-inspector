import UIKit

class OptionsTableViewController: UITableViewController {

    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sections.maybeAppend(makeGeneralSection())
        self.sections.maybeAppend(makeStatusSection())
        self.sections.maybeAppend(makeFingerprintSection())
        self.sections.maybeAppend(makeAdvancedSection())

        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }

    func makeGeneralSection() -> TableViewSection? {
        let generalSection = TableViewSection()
        generalSection.title = lang(key: "General")
        generalSection.cells.append(SwitchTableViewCell(labelText: lang(key: "Remember Recent Lookups"), defaultChecked: UserOptions.rememberRecentLookups, didChange: { checked in
            UserOptions.rememberRecentLookups = checked
            if !checked {
                RecentLookups.RemoveAllLookups()
            }
            NotificationCenter.default.post(name: RELOAD_RECENT_NOTIFICATION, object: nil)
        }))
        generalSection.cells.append(SwitchTableViewCell(labelText: lang(key: "Show HTTP Headers"), defaultChecked: UserOptions.getHTTPHeaders, didChange: { checked in
            UserOptions.getHTTPHeaders = checked
        }))
        generalSection.cells.append(SwitchTableViewCell(labelText: lang(key: "Show Tips"), defaultChecked: UserOptions.showTips, didChange: { checked in
            UserOptions.showTips = checked
            NotificationCenter.default.post(name: SHOW_TIPS_NOTIFICATION, object: nil)
        }))
        generalSection.cells.append(SwitchTableViewCell(labelText: lang(key: "Treat Unrecognized as Trusted"), defaultChecked: UserOptions.treatUnrecognizedAsTrusted, didChange: { checked in
            UserOptions.treatUnrecognizedAsTrusted = checked
        }))
        if let tableCell = self.tableView.dequeueReusableCell(withIdentifier: "Basic") {
            tableCell.textLabel?.text = lang(key: "App Icons")
            let cell = TableViewCell(tableCell)
            cell.didSelect = { (_, _) in
                self.performSegue(withIdentifier: "AppIconSegue", sender: nil)
            }
            generalSection.cells.append(cell)
        }

        if generalSection.cells.count > 0 {
            return generalSection
        }

        return nil
    }

    func makeStatusSection() -> TableViewSection? {
        let statusSection = TableViewSection()
        statusSection.title = lang(key: "Certificate Status")
        statusSection.footer = lang(key: "certificate_status_footer")
        statusSection.cells.append(SwitchTableViewCell(labelText: lang(key: "Query OCSP Responder"), defaultChecked: UserOptions.queryOCSP, didChange: { checked in
            UserOptions.queryOCSP = checked
        }))
        statusSection.cells.append(SwitchTableViewCell(labelText: lang(key: "Download & Check CRL"), defaultChecked: UserOptions.checkCRL, didChange: { checked in
            UserOptions.checkCRL = checked
        }))

        if statusSection.cells.count > 0 {
            return statusSection
        }

        return nil
    }

    func makeFingerprintSection() -> TableViewSection? {
        let fingerprintSection = TableViewSection()
        fingerprintSection.title = lang(key: "Fingerprints")
        fingerprintSection.cells.append(SwitchTableViewCell(labelText: lang(key: "MD5"), defaultChecked: UserOptions.showFingerprintMD5, didChange: { checked in
            UserOptions.showFingerprintMD5 = checked
        }))
        fingerprintSection.cells.append(SwitchTableViewCell(labelText: lang(key: "SHA1"), defaultChecked: UserOptions.showFingerprintSHA128, didChange: { checked in
            UserOptions.showFingerprintSHA128 = checked
        }))
        fingerprintSection.cells.append(SwitchTableViewCell(labelText: lang(key: "SHA-256"), defaultChecked: UserOptions.showFingerprintSHA256, didChange: { checked in
            UserOptions.showFingerprintSHA256 = checked
        }))
        fingerprintSection.cells.append(SwitchTableViewCell(labelText: lang(key: "SHA-512"), defaultChecked: UserOptions.showFingerprintSHA512, didChange: { checked in
            UserOptions.showFingerprintSHA512 = checked
        }))

        if fingerprintSection.cells.count > 0 {
            return fingerprintSection
        }

        return nil
    }

    func makeAdvancedSection() -> TableViewSection? {
        let generalSection = TableViewSection()
        if let cell = newIconCell(labelText: "Advanced Options",
                                  icon: .FACogSolid,
                                  iconColor: UIColor.systemBlue) {
            cell.didSelect = { (_, _) in
                self.performSegue(withIdentifier: "Advanced", sender: nil)
            }
            generalSection.cells.append(cell)
        }

        if generalSection.cells.count > 0 {
            return generalSection
        }

        return nil
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.sections[indexPath.section].cells[indexPath.row].cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        self.sections[section].footer
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.sections[indexPath.section].cells[indexPath.row]
        if let didSelect = cell.didSelect {
            didSelect(tableView, indexPath)
        }
    }

    func newSwitchCell(labelText: String, initialValue: Bool, changed: Selector) -> TableViewCell? {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Switch") else { return nil }
        guard let label = cell.viewWithTag(1) as? UILabel else { return nil }
        guard let toggle = cell.viewWithTag(2) as? UISwitch else { return nil }

        label.text = lang(key: labelText)
        toggle.setOn(initialValue, animated: false)
        toggle.addTarget(self, action: changed, for: .valueChanged)
        cell.accessibilityLabel = labelText
        cell.selectionStyle = .none

        return TableViewCell(cell)
    }

    func newIconCell(labelText: String, icon: FAIcon, iconColor: UIColor) -> TableViewCell? {
        guard let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Icon")) else { return nil }
        guard let label = cell.cell.viewWithTag(1) as? UILabel else { return nil }
        guard let iconLabel = cell.cell.viewWithTag(2) as? UILabel else { return nil }
        label.text = lang(key: labelText)
        iconLabel.font = icon.font(size: iconLabel.font.pointSize)
        iconLabel.textColor = iconColor
        iconLabel.text = icon.string()
        cell.cell.accessibilityLabel = labelText

        return cell
    }
}
