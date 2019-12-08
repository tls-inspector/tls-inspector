import UIKit
import CertificateKit

class SANListTableViewController: UITableViewController {
    var altrnateNames: [CKAlternateNameObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let certificate = CERTIFICATE_CHAIN?.certificates[CURRENT_CERTIFICATE] else {
            return
        }

        guard let altNames = certificate.alternateNames else {
            return
        }

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
        var type: String = lang(key: "Unknown")
        switch altName.type {
        case .directory:
            type = lang(key: "Directory")
        case .DNS:
            type = lang(key: "DNS")
        case .other:
            type = lang(key: "Other")
        case .email:
            type = lang(key: "Email")
        case .IP:
            type = lang(key: "IP")
        case .URI:
            type = lang(key: "URI")
        @unknown default:
            break
        }
        return TitleValueTableViewCell.Cell(title: type, value: altName.value, useFixedWidthFont: true)
    }
}
