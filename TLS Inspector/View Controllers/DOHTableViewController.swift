import UIKit

private struct PresetDOHServer {
    let name: String
    let server: DOHServer
}

class DOHTableViewController: UITableViewController {
    var sections: [TableViewSection] = []

    private let presetServers: [PresetDOHServer] = [
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
        if self.sections.count == 3 {
            self.sections.remove(at: 2)
        }
        if self.sections.count == 2 {
            self.sections.remove(at: 1)
        }
        self.sections.maybeAppend(self.buildServerListSection())
        self.sections.maybeAppend(self.buildCustomSection())
    }

    func buildEnabledSection() -> TableViewSection {
        let section = TableViewSection()

        let cell = SwitchTableViewCell(labelText: lang(key: "Enabled"), defaultChecked: UserOptions.dohServer != nil, didChange: { enabled in
            UserOptions.dohServer = enabled ? self.presetServers[0].server : nil
            self.buildTable()
            if enabled {
                self.tableView.insertSections(IndexSet(integer: 1), with: .fade)
            } else {
                self.tableView.deleteSections(IndexSet(integer: 1), with: .fade)
            }
        })
        section.cells.append(cell)

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
                    self.tableView.deleteSections(IndexSet(integer: 2), with: .fade)
                }
                self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
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
                self.tableView.insertSections(IndexSet(integer: 2), with: .fade)
            }
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
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
        section.footer = lang(key: "TLS Inspector supports UDP wireformat requests.")

        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "Input") {
            if let input = cell.viewWithTag(1) as? UITextField {
                input.placeholder = lang(key: "https://www.example.com/dns-query")
                input.addTarget(self, action: #selector(urlTextChanged), for: .valueChanged)
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

    @objc func urlTextChanged(sender: UITextField) {
        UserOptions.dohServer?.url = sender.text ?? ""
    }

    @IBAction func doneButtonTap(_ sender: UIBarButtonItem) {
        if UserOptions.dohServer?.custom ?? false {
            sender.isEnabled = false

            // Validate
        }

        self.dismiss(animated: true)
    }
}
