import UIKit
import CertificateKit

private struct PresetDOHServer {
    let name: String
    let server: DOHServer
}

class DOHTableViewController: UITableViewController {
    var sections: [TableViewSection] = []

    private let presetServers: [PresetDOHServer] = [
        PresetDOHServer(name: "Wikimedia", server: DOHServer(url: "https://wikimedia-dns.org/dns-query", custom: false)),
        PresetDOHServer(name: "Google", server: DOHServer(url: "https://dns.google/dns-query", custom: false)),
        PresetDOHServer(name: "Cloudflare", server: DOHServer(url: "https://cloudflare-dns.com/dns-query", custom: false)),
        PresetDOHServer(name: "Quad9", server: DOHServer(url: "https://dns10.quad9.net/dns-query", custom: false)),
    ]

    @IBOutlet weak var doneButton: UIBarButtonItem!

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
        section.footer = lang(key: "doh_description")

        let enabledCell = SwitchTableViewCell(labelText: lang(key: "Enabled"), defaultChecked: UserOptions.dohServer != nil, didChange: { enabled in
            UserOptions.dohServer = enabled ? self.presetServers[0].server : nil
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
        if UserOptions.dohServer == nil {
            return nil
        }

        let section = TableViewSection()
        section.footer = lang(key: "doh_fallback_description")

        let fallbackCell = SwitchTableViewCell(labelText: lang(key: "Use System DNS on Error"), defaultChecked: UserOptions.dohFallback, didChange: { enabled in
            UserOptions.dohFallback = enabled
        })
        section.cells.append(fallbackCell)

        return section
    }

    func buildServerListSection() -> TableViewSection? {
        guard let currentServer = UserOptions.dohServer else {
            return nil
        }

        let section = TableViewSection()
        section.title = lang(key: "Servers")

        for preset in presetServers {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Basic") else {
                return section
            }

            cell.textLabel?.text = preset.name
            if currentServer.url == preset.server.url {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            let tvc = TableViewCell(cell)
            tvc.didSelect = { (_, _) in
                let currentServerIsCustom = UserOptions.dohServer?.custom ?? false
                UserOptions.dohServer = preset.server
                self.buildTable()
                if currentServerIsCustom {
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
        if currentServer.custom {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        let tvc = TableViewCell(cell)
        tvc.didSelect = { (_, _) in
            let currentServerIsCustom = UserOptions.dohServer?.custom ?? false
            UserOptions.dohServer = DOHServer(url: "", custom: true)
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
        guard let server = UserOptions.dohServer else {
            return nil
        }
        if !server.custom {
            return nil
        }

        let section = TableViewSection()
        section.title = lang(key: "Custom Server URL")
        section.footer = lang(key: "TLS Inspector supports UDP wireformat servers")

        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "Input") {
            if let input = cell.viewWithTag(1) as? UITextField {
                input.placeholder = "https://www.example.com/dns-query"
                input.text = server.url
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

    @IBAction func doneButtonTap(_ sender: UIBarButtonItem) {
        if UserOptions.dohServer?.custom ?? false {
            sender.isEnabled = false

            guard let urlField = self.sections[2].cells[0].cell.viewWithTag(1) as? UITextField else {
                return
            }
            let url = urlField.text ?? ""

            // Validate
            self.doneButton.isEnabled = false
            CKDNSClient.shared().resolve("dns.google", ofAddressVersion: .automatic, onServer: url) { res, err in
                RunOnMain {
                    self.doneButton.isEnabled = true
                }

                if let error = err {
                    UIHelper(self).presentError(error: error, dismissed: nil)
                    return
                }

                guard let result = res else {
                    return
                }

                guard let addresses = try? result.addresses(forName: "dns.google") else {
                    UIHelper(self).presentAlert(title: lang(key: ""), body: lang(key: ""), dismissed: nil)
                    return
                }

                if addresses.count == 0 {
                    UIHelper(self).presentAlert(title: lang(key: ""), body: lang(key: ""), dismissed: nil)
                    return
                }

                if addresses[0] != "8.8.8.8" {
                    UIHelper(self).presentAlert(title: lang(key: ""), body: lang(key: ""), dismissed: nil)
                    return
                }

                RunOnMain {
                    UserOptions.dohServer?.url = url
                    self.dismiss(animated: true)
                }
            }
        } else {
            self.dismiss(animated: true)
        }
    }
}
