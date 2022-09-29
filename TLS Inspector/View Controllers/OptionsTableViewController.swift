import UIKit

class OptionsTableViewController: UITableViewController {

    var sections: [TableViewSection] = []
    let advancedOptionsCellTag = 101

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sections.maybeAppend(makeGeneralSection())
        self.sections.maybeAppend(makeStatusSection())
        self.sections.maybeAppend(makeFingerprintSection())
        self.sections.maybeAppend(makeAdvancedSection())
    }

    func makeGeneralSection() -> TableViewSection? {
        let generalSection = TableViewSection()
        generalSection.title = lang(key: "General")
        if let cell = newSwitchCell(labelText: lang(key: "Remember Recent Lookups"),
                                    initialValue: UserOptions.rememberRecentLookups,
                                    changed: #selector(changeRememberLookups(sender:))) {
            generalSection.cells.append(cell)
        }
        if let cell = newSwitchCell(labelText: lang(key: "Show HTTP Headers"),
                                    initialValue: UserOptions.getHTTPHeaders,
                                    changed: #selector(changeShowHTTPHeaders(sender:))) {
            generalSection.cells.append(cell)
        }
        if let cell = newSwitchCell(labelText: lang(key: "Show Tips"),
                                    initialValue: UserOptions.showTips,
                                    changed: #selector(changeShowTips(sender:))) {
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
        if let cell = newSwitchCell(labelText: lang(key: "Query OCSP Responder"),
                                    initialValue: UserOptions.queryOCSP,
                                    changed: #selector(changeQueryOCSP(sender:))) {
            statusSection.cells.append(cell)
        }
        if let cell = newSwitchCell(labelText: lang(key: "Download & Check CRL"),
                                    initialValue: UserOptions.checkCRL,
                                    changed: #selector(changeCheckCRL(sender:))) {
            statusSection.cells.append(cell)
        }

        if statusSection.cells.count > 0 {
            return statusSection
        }

        return nil
    }

    func makeFingerprintSection() -> TableViewSection? {
        let fingerprintSection = TableViewSection()
        fingerprintSection.title = lang(key: "Fingerprints")
        if let cell = newSwitchCell(labelText: lang(key: "MD5"),
                                    initialValue: UserOptions.showFingerprintMD5,
                                    changed: #selector(changeShowFingerprintMD5(sender:))) {
            fingerprintSection.cells.append(cell)
        }
        if let cell = newSwitchCell(labelText: lang(key: "SHA1"),
                                    initialValue: UserOptions.showFingerprintSHA128,
                                    changed: #selector(changeShowFingerprintSHA128(sender:))) {
            fingerprintSection.cells.append(cell)
        }
        if let cell = newSwitchCell(labelText: lang(key: "SHA-256"),
                                    initialValue: UserOptions.showFingerprintSHA256,
                                    changed: #selector(changeShowFingerprintSHA256(sender:))) {
            fingerprintSection.cells.append(cell)
        }
        if let cell = newSwitchCell(labelText: lang(key: "SHA-512"),
                                    initialValue: UserOptions.showFingerprintSHA512,
                                    changed: #selector(changeShowFingerprintSHA512(sender:))) {
            fingerprintSection.cells.append(cell)
        }

        if fingerprintSection.cells.count > 0 {
            return fingerprintSection
        }

        return nil
    }

    func makeAdvancedSection() -> TableViewSection? {
        let generalSection = TableViewSection()
        if let cell = newIconCell(labelText: lang(key: "Advanced Options"),
                                  icon: .FACogSolid,
                                  iconColor: UIColor.systemBlue) {
            cell.cell.tag = advancedOptionsCellTag
            generalSection.cells.append(cell)
        }

        if generalSection.cells.count > 0 {
            return generalSection
        }

        return nil
    }

    @objc func changeRememberLookups(sender: UISwitch) {
        UserOptions.rememberRecentLookups = sender.isOn
        if !sender.isOn {
            RecentLookups.RemoveAllLookups()
        }
        NotificationCenter.default.post(name: RELOAD_RECENT_NOTIFICATION, object: nil)
    }

    @objc func changeShowHTTPHeaders(sender: UISwitch) {
        UserOptions.getHTTPHeaders = sender.isOn
    }

    @objc func changeShowTips(sender: UISwitch) {
        UserOptions.showTips = sender.isOn
        NotificationCenter.default.post(name: SHOW_TIPS_NOTIFICATION, object: nil)
    }

    @objc func changeQueryOCSP(sender: UISwitch) {
        UserOptions.queryOCSP = sender.isOn
    }

    @objc func changeCheckCRL(sender: UISwitch) {
        UserOptions.checkCRL = sender.isOn
    }

    @objc func changeShowFingerprintMD5(sender: UISwitch) {
        UserOptions.showFingerprintMD5 = sender.isOn
    }

    @objc func changeShowFingerprintSHA128(sender: UISwitch) {
        UserOptions.showFingerprintSHA128 = sender.isOn
    }

    @objc func changeShowFingerprintSHA256(sender: UISwitch) {
        UserOptions.showFingerprintSHA256 = sender.isOn
    }

    @objc func changeShowFingerprintSHA512(sender: UISwitch) {
        UserOptions.showFingerprintSHA512 = sender.isOn
    }

    @objc func changeVerboseLogging(sender: UISwitch) {
        UserOptions.verboseLogging = sender.isOn
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
        let cellTag = self.sections[indexPath.section].cells[indexPath.row].cell.tag
        if cellTag == advancedOptionsCellTag {
            self.performSegue(withIdentifier: "Advanced", sender: nil)
        }
    }

    func newSwitchCell(labelText: String, initialValue: Bool, changed: Selector) -> TableViewCell? {
        guard let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Switch")) else { return nil }
        guard let label = cell.cell.viewWithTag(1) as? UILabel else { return nil }
        guard let toggle = cell.cell.viewWithTag(2) as? UISwitch else { return nil }

        label.text = labelText
        toggle.setOn(initialValue, animated: false)
        toggle.addTarget(self, action: changed, for: .valueChanged)

        return cell
    }

    func newIconCell(labelText: String, icon: FAIcon, iconColor: UIColor) -> TableViewCell? {
        guard let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Icon")) else { return nil }
        guard let label = cell.cell.viewWithTag(1) as? UILabel else { return nil }
        guard let iconLabel = cell.cell.viewWithTag(2) as? UILabel else { return nil }
        label.text = labelText
        iconLabel.font = icon.font(size: iconLabel.font.pointSize)
        iconLabel.textColor = iconColor
        iconLabel.text = icon.string()

        return cell
    }
}
