import UIKit
import CertificateKit

class SANListTableViewController: UITableViewController {
    var altrnateNames: [CKAlternateNameObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let certificate = CERTIFICATE_CHAIN?.certificates[CURRENT_CERTIFICATE] else { return }

        guard let altNames = certificate.alternateNames else { return }

        self.altrnateNames = altNames
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.altrnateNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let altName = self.altrnateNames[indexPath.row]
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
        return TitleValueTableViewCell.Cell(title: type, value: altName.value, useFixedWidthFont: true).cell
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            var data: String?
            let tableCell = tableView.cellForRow(at: indexPath)!
            if let titleValueCell = tableCell as? TitleValueTableViewCell {
                data = titleValueCell.valueLabel.text
            } else {
                data = tableCell.textLabel?.text
            }
            UIPasteboard.general.string = data
        }
    }
}
