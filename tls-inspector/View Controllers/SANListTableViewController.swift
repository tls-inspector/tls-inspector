import UIKit
import CertificateKit

class SANListTableViewController: UITableViewController {
    var cells: [TableViewCell] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let certificate = CERTIFICATE_CHAIN?.certificates[CURRENT_CERTIFICATE] else { return }
        guard let altNames = certificate.alternateNames else { return }

        for altName in altNames {
            var type: String = lang(key: "sanType::Unknown")
            switch altName.type {
            case .directory:
                type = lang(key: "sanType::Directory")
            case .DNS:
                type = lang(key: "sanType::DNS")
            case .other:
                type = lang(key: "sanType::Other")
            case .email:
                type = lang(key: "sanType::Email")
            case .IP:
                type = lang(key: "sanType::IP")
            case .URI:
                type = lang(key: "sanType::URI")
            @unknown default:
                break
            }
            self.cells.append(TitleValueTableViewCell.Cell(title: type, value: altName.value, useFixedWidthFont: true))
        }
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
