import UIKit

class OptionsTableViewController: UITableViewController {

    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if let cell = newIconCell(labelText: lang(key: "Advanced Options"),
                                  icon: .FACogSolid,
                                  iconColor: UIColor.systemBlue) {
            generalSection.cells.append(cell)
        }
        self.sections.append(generalSection)

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
        self.sections.append(statusSection)
    }

    @objc func changeRememberLookups(sender: UISwitch) {

    }

    @objc func changeShowHTTPHeaders(sender: UISwitch) {

    }

    @objc func changeShowTips(sender: UISwitch) {

    }

    @objc func changeQueryOCSP(sender: UISwitch) {

    }

    @objc func changeCheckCRL(sender: UISwitch) {

    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.sections[indexPath.section].cells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        self.sections[section].footer
    }

    func newSwitchCell(labelText: String, initialValue: Bool, changed: Selector) -> UITableViewCell? {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Switch") else {
            return nil
        }
        guard let label = cell.viewWithTag(1) as? UILabel else {
            return nil
        }
        guard let toggle = cell.viewWithTag(2) as? UISwitch else {
            return nil
        }

        label.text = labelText
        toggle.setOn(initialValue, animated: false)
        toggle.addTarget(self, action: changed, for: .editingChanged)

        return cell
    }

    func newIconCell(labelText: String, icon: FAIcon, iconColor: UIColor) -> UITableViewCell? {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Icon") else {
            return nil
        }
        guard let label = cell.viewWithTag(1) as? UILabel else {
            return nil
        }
        guard let iconLabel = cell.viewWithTag(2) as? UILabel else {
            return nil
        }
        label.text = labelText
        iconLabel.font = icon.font(size: iconLabel.font.pointSize)
        iconLabel.textColor = iconColor
        iconLabel.text = icon.string()

        return cell
    }
}
