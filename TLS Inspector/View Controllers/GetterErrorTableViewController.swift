import UIKit

class GetterErrorTableViewController: UITableViewController {
    public var chainError: Error?
    public var serverError: Error?
    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let section = TableViewSection()
        if let error = self.chainError {
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Certificate Chain"),
                                                              value: error.localizedDescription))
        }
        if let error = self.serverError {
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Server Info"),
                                                              value: error.localizedDescription))
        }
        self.sections.append(section)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cells[indexPath.row]
    }
}
