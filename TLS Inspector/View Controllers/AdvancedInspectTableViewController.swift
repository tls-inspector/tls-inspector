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

    // MARK: - Table view data source
    func buildTable() {
        self.sections = []
        self.sections.maybeAppend(self.buildTargetSection())
    }

    func buildTargetSection() -> TableViewSection? {
        let section = TableViewSection()
        section.title = lang(key: "Target")

        let hostInput = InputTableViewCell.Cell(title: lang(key: "Domain name or IP Address")) { (input: UITextField) in
            input.placeholder = lang(key: "www.nsa.gov")
        } valueDidChange: { (value: String) in
            if let url = URL(string: value) {
                self.parameters.queryURL = url
            }
        }

        let ipAddressInput = InputTableViewCell.Cell(title: lang(key: "Host IP Address")) { (input: UITextField) in
            input.placeholder = lang(key: "Optional")
        } valueDidChange: { (value: String) in
            self.parameters.ipAddress = value
        }

        section.cells = [hostInput, ipAddressInput]

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
