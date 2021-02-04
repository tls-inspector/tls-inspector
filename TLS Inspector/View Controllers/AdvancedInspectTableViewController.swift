import UIKit
import CertificateKit

class AdvancedInspectTableViewController: UITableViewController {
    private var parameters: CKGetterParameters = CKGetterParameters()
    public var donePressed: ((_ parameters: CKGetterParameters) -> Void)?
    private var sections: [TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildTable()
    }

    // MARK: - Title bar buttons
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            guard let done = self.donePressed else {
                return
            }

            done(self.parameters)
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func changeIPVersion(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            parameters.ipVersion = IP_VERSION_AUTOMATIC
        case 1:
            parameters.ipVersion = IP_VERSION_IPV4
        case 2:
            parameters.ipVersion = IP_VERSION_IPV6
        default:
            break
        }
    }

    // MARK: - Table view data source
    func buildTable() {
        self.sections = []
        self.sections.maybeAppend(self.buildTargetSection())
        self.sections.maybeAppend(self.buildNetworkSection())
    }

    func buildTargetSection() -> TableViewSection? {
        let section = TableViewSection()
        section.title = lang(key: "Target")
        section.footer = lang(key: "Specify an IP address to bypass name resolution")

        let hostInput = InputTableViewCell.Cell(title: lang(key: "Domain name or IP Address")) { (input: UITextField) in
            input.placeholder = lang(key: "www.nsa.gov")
            input.keyboardType = .URL
            input.autocorrectionType = .no
            input.spellCheckingType = .no
        } valueDidChange: { (value: String) in
            var urlStr = value
            if !urlStr.hasPrefix("https://") {
                urlStr = "https://" + urlStr
            }

            if let url = URL(string: urlStr) {
                self.parameters.queryURL = url
            }
        }

        let ipAddressInput = InputTableViewCell.Cell(title: lang(key: "Host IP Address")) { (input: UITextField) in
            input.placeholder = lang(key: "Optional")
            input.keyboardType = .asciiCapable
            input.autocorrectionType = .no
            input.spellCheckingType = .no
        } valueDidChange: { (value: String) in
            self.parameters.ipAddress = value
        }

        section.cells = [hostInput, ipAddressInput]

        return section
    }

    func buildNetworkSection() -> TableViewSection? {
        let section = TableViewSection()
        section.title = lang(key: "Network")

        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "IPVSegment") else {
            return nil
        }

        cell.selectionStyle = .none

        guard let segment = cell.viewWithTag(1) as? UISegmentedControl else {
            return nil
        }

        switch self.parameters.ipVersion {
        case IP_VERSION_AUTOMATIC:
            segment.selectedSegmentIndex = 0
        case IP_VERSION_IPV4:
            segment.selectedSegmentIndex = 1
        case IP_VERSION_IPV6:
            segment.selectedSegmentIndex = 2
        default:
            break
        }
        segment.addTarget(self, action: #selector(changeIPVersion(sender:)), for: .valueChanged)

        section.cells = [cell]

        return section
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sections[section].footer
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cells[indexPath.row]
    }
}
