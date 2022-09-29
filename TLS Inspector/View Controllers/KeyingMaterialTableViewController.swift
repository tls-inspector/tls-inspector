import UIKit
import CertificateKit

class KeyingMaterialTableViewController: UITableViewController {
    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        guard let chain = CERTIFICATE_CHAIN else { return }
        guard let keyLog = chain.keyLog else { return }

        let lines = keyLog.split(separator: "\n")
        for line in lines {
            let parts = line.split(separator: " ")
            if parts.count != 3 {
                continue
            }
            let label = String(parts[0])
            let clientRandom = String(parts[1])
            let secret = String(parts[2])

            let section = TableViewSection()
            section.title = label
            section.cells = [
                TitleValueTableViewCell.Cell(title: lang(key: "Client Random"), value: clientRandom, useFixedWidthFont: true),
                TitleValueTableViewCell.Cell(title: lang(key: "Secret"), value: secret, useFixedWidthFont: true)
            ]

            sections.append(section)
        }

        super.viewDidLoad()
    }

    @IBAction func actionButtonPress(_ sender: UIBarButtonItem) {
        UIHelper(self).presentActionSheet(target: ActionTipTarget.init(barButtonItem: sender), title: nil, subtitle: nil, items: [lang(key: "Export NSS Keylog")]) { idx in
            if idx == 0 {
                self.exportKeylog(sender)
            }
        }
    }

    func exportKeylog(_ sender: UIBarButtonItem) {
        guard let chain = CERTIFICATE_CHAIN else { return }
        guard let keyLog = chain.keyLog?.data(using: .utf8) else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let header = String(format: "# Generated on %@ by TLS Inspector v%@ (%@) using OpenSSL %@\n", formatter.string(from: Date()), AppInfo.version(), AppInfo.build(), CertificateKit.opensslVersion())
        guard var keylogFileData = header.data(using: .utf8) else { return }
        keylogFileData.append(keyLog)

        let fileName = "keylog.txt"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do {
            try keylogFileData.write(to: fileURL)
        } catch {
            UIHelper(self).presentError(error: error, dismissed: nil)
            return
        }
        let activityController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        ActionTipTarget(barButtonItem: sender).attach(to: activityController.popoverPresentationController)
        self.present(activityController, animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
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
