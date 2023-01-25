import UIKit

class CertificateTimestampsTableViewController: UITableViewController {
    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let certificate = CERTIFICATE_CHAIN?.certificates[CURRENT_CERTIFICATE] else { return }
        guard let timestamps = certificate.signedTimestamps else { return }

        for timestamp in timestamps {
            let section = TableViewSection()
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Log ID"), value: timestamp.logId, useFixedWidthFont: true))

            if let cell = self.tableView.dequeueReusableCell(withIdentifier: "Detail") {
                cell.textLabel?.text = lang(key: "Timestamp")

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm 'UTC'"

                cell.detailTextLabel?.text = formatter.string(from: timestamp.timestamp)
                section.cells.append(TableViewCell(cell))
            }
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: "Detail") {
                cell.textLabel?.text = lang(key: "Signature Type")
                cell.detailTextLabel?.text = timestamp.signatureType
                section.cells.append(TableViewCell(cell))
            }
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Signature"), value: timestamp.signature, useFixedWidthFont: true))

            self.sections.append(section)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cells[indexPath.row].cell
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if let shouldShowMenu = self.sections[indexPath.section].cells[indexPath.row].shouldShowMenu {
            return shouldShowMenu(tableView, indexPath)
        }
        return false
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if let canPerformAction = self.sections[indexPath.section].cells[indexPath.row].canPerformAction {
            return canPerformAction(tableView, action, indexPath, sender)
        }
        return false
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if let performAction = self.sections[indexPath.section].cells[indexPath.row].performAction {
            return performAction(tableView, action, indexPath, sender)
        }
        return
    }
}
