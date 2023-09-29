import UIKit
import CertificateKit

private struct PresetSecureDNSServer {
    let name: String
    let host: String
}

class SecureDNSTableViewController: UITableViewController {
    var settings = UserOptions.secureDNS
    var sections: [TableViewSection] = []

    private let presetServers: [PresetSecureDNSServer] = [
        PresetSecureDNSServer(name: "Wikimedia", host: "https://wikimedia-dns.org/dns-query"),
        PresetSecureDNSServer(name: "Google", host: "https://dns.google/dns-query"),
        PresetSecureDNSServer(name: "Cloudflare", host: "https://cloudflare-dns.com/dns-query"),
        PresetSecureDNSServer(name: "Quad9", host: "https://dns10.quad9.net/dns-query"),
    ]

    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildTable()
        self.tableView.reloadData()
    }

    func buildTable() {
        if self.sections.count == 0 {
            self.sections = [
                self.buildEnabledSection()
            ]
        }
        if self.sections.count == 4 {
            self.sections.remove(at: 3)
        }
        if self.sections.count == 3 {
            self.sections.remove(at: 2)
        }
        if self.sections.count == 2 {
            self.sections.remove(at: 1)
        }
        self.sections.maybeAppend(self.buildFallbackSection())
        self.sections.maybeAppend(self.buildServerListSection())
        self.sections.maybeAppend(self.buildCustomSection())
    }

    func buildEnabledSection() -> TableViewSection {
        let section = TableViewSection()
        section.footer = lang(key: "securedns_description")

        let enabledCell = SwitchTableViewCell(labelText: lang(key: "Enabled"), defaultChecked: self.settings.mode != .Disabled, didChange: { enabled in
            self.settings.mode = enabled ? .HTTPS : .Disabled
            if enabled && self.settings.host == nil {
                self.settings.host = self.presetServers[0].host
                self.settings.custom = false
                self.settings.fallback = true
            }
            if !enabled {
                self.settings.host = nil
            }
            self.buildTable()
            if enabled {
                self.tableView.insertSections(IndexSet(1...2), with: .fade)
            } else {
                self.tableView.deleteSections(IndexSet(1...2), with: .fade)
            }
        })
        section.cells.append(enabledCell)

        return section
    }

    func buildFallbackSection() -> TableViewSection? {
        if self.settings.mode == .Disabled {
            return nil
        }

        let section = TableViewSection()
        section.footer = lang(key: "securedns_fallback_description")

        let fallbackCell = SwitchTableViewCell(labelText: lang(key: "Use System DNS on Error"), defaultChecked: self.settings.fallback ?? false, didChange: { enabled in
            self.settings.fallback = enabled
        })
        section.cells.append(fallbackCell)

        return section
    }

    func buildServerListSection() -> TableViewSection? {
        if self.settings.mode == .Disabled {
            return nil
        }
        guard let currentServer = self.settings.host else {
            return nil
        }

        let section = TableViewSection()
        section.title = lang(key: "Servers")

        for preset in presetServers {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Basic") else {
                return section
            }

            cell.textLabel?.text = preset.name
            if currentServer == preset.host && !(self.settings.custom ?? false) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            let tvc = TableViewCell(cell)
            tvc.didSelect = { (_, _) in
                self.settings.host = preset.host
                let wasCustom = self.settings.custom ?? false
                self.settings.custom = false
                self.buildTable()
                if wasCustom {
                    self.tableView.deleteSections(IndexSet(integer: 3), with: .fade)
                }
                self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
            }
            section.cells.append(tvc)
        }

        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Basic") else {
            return section
        }

        cell.textLabel?.text = lang(key: "Custom")
        if self.settings.custom ?? false {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        let tvc = TableViewCell(cell)
        tvc.didSelect = { (_, _) in
            let currentServerIsCustom = self.settings.custom ?? false
            self.settings.host = ""
            self.settings.custom = true
            self.buildTable()
            if !currentServerIsCustom {
                self.tableView.insertSections(IndexSet(integer: 3), with: .fade)
            }
            self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
        }
        section.cells.append(tvc)

        return section
    }

    func buildCustomSection() -> TableViewSection? {
        if !(self.settings.custom ?? false) {
            return nil
        }

        let section = TableViewSection()
        section.title = lang(key: "Custom Server URL")
        section.footer = lang(key: "TLS Inspector supports UDP wireformat servers")

        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "Input") {
            if let input = cell.viewWithTag(1) as? UITextField {
                input.placeholder = "https://www.example.com/dns-query"
                input.text = self.settings.host ?? ""
            }
            section.cells.append(TableViewCell(cell))
        }

        return section
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cells[indexPath.row].cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.sections[indexPath.section].cells[indexPath.row]
        cell.didSelect?(tableView, indexPath)
    }

    func validateCustom(complete: @escaping (String?, String?) -> Void) {
        guard let urlField = self.sections[3].cells[0].cell.viewWithTag(1) as? UITextField else {
            complete(nil, lang(key: "Unknown"))
            return
        }

        guard var url = urlField.text else {
            complete(nil, lang(key: "Invalid host"))
            return
        }

        if url.count == 0 {
            complete(nil, lang(key: "Invalid host"))
            return
        }

        if !url.hasPrefix("https://") {
            if url.contains("://") {
                complete(nil, lang(key: "Unsupported protocol"))
                return
            } else {
                url = "https://" + url
            }
        }

        CKDNSClient.shared().resolve("dns.google", ofAddressVersion: .iPv4, onServer: url) { res, err in
            if let error = err {
                complete(nil, error.localizedDescription)
                return
            }

            guard let result = res else {
                complete(nil, lang(key: "No response"))
                return
            }

            guard let addresses = try? result.addresses(forName: "dns.google") else {
                complete(nil, lang(key: "Unexpected response"))
                return
            }

            if addresses.count == 0 {
                complete(nil, lang(key: "No response"))
                return
            }

            if addresses[0] != "8.8.8.8" {
                complete(nil, lang(key: "Unexpected response"))
                return
            }

            complete(url, nil)
        }
    }

    @IBAction func saveButtonTap(_ sender: UIBarButtonItem) {
        if self.settings.custom ?? false {
            let pendingView = UIHelper.activityAlertView(title: lang(key: "Validating server"))
            self.present(pendingView, animated: true) {
                self.validateCustom { url, errorDescription in
                    RunOnMain {
                        pendingView.dismiss(animated: true) {
                            self.saveButton.isEnabled = true
                            if let error = errorDescription {
                                UIHelper(self).presentAlert(title: lang(key: "Error Validating Server"), body: error, dismissed: nil)
                                return
                            }
                            self.settings.host = url
                            UserOptions.secureDNS = self.settings
                            self.dismiss(animated: true)
                        }
                    }
                }
            }
        } else {
            UserOptions.secureDNS = self.settings
            self.dismiss(animated: true)
        }
    }

    @IBAction func cancelButtonTap(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
