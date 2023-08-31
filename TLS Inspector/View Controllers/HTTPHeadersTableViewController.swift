import UIKit
import CertificateKit

class HTTPHeadersTableViewController: UITableViewController {
    var cells: [TableViewCell] = []

    override func viewDidLoad() {
        guard let serverInfo = HTTP_SERVER_INFO else { return }
        let headerKeysSorted = serverInfo.headers.keys.sorted()

        for key in headerKeysSorted {
            for value in serverInfo.headers[key] ?? [] {
                self.cells.append(TitleValueTableViewCell.Cell(title: key, value: value, useFixedWidthFont: true))
            }
        }

        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cells[indexPath.row].cell
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if let shouldShowMenu = self.cells[indexPath.row].shouldShowMenu {
            return shouldShowMenu(tableView, indexPath)
        }
        return false
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if let canPerformAction = self.cells[indexPath.row].canPerformAction {
            return canPerformAction(tableView, action, indexPath, sender)
        }
        return false
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if let performAction = self.cells[indexPath.row].performAction {
            return performAction(tableView, action, indexPath, sender)
        }
        return
    }
}
