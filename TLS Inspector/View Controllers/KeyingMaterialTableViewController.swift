import UIKit
import CertificateKit

class KeyingMaterialTableViewController: UITableViewController {
    var keys: [[String]] = []

    override func viewDidLoad() {
        guard let chain = CERTIFICATE_CHAIN else {
            return
        }
        guard let keyLog = chain.keyLog else {
            return
        }

        let lines = keyLog.split(separator: "\n")
        for line in lines {
            let parts = line.split(separator: " ")
            if parts.count != 3 {
                continue
            }
            let label = String(parts[0])
            let clientRandom = String(parts[1])
            let secret = String(parts[2])
            keys.append([label, clientRandom, secret])
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
        guard let chain = CERTIFICATE_CHAIN else {
            return
        }
        guard let keyLog = chain.keyLog?.data(using: .utf8) else {
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let header = String(format: "# Generated on %@ by TLS Inspector v%@ (%@) using OpenSSL %@\n", formatter.string(from: Date()), AppInfo.version(), AppInfo.build(), CertificateKit.opensslVersion())
        guard var keylogFileData = header.data(using: .utf8) else {
            return
        }
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
        return keys.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = self.keys[section]
        return key[0]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = self.keys[indexPath.section]
        let clientRandom = key[1]
        let secret = key[2]

        if indexPath.row == 0 {
            return TitleValueTableViewCell.Cell(title: lang(key: "Client Random"), value: clientRandom, useFixedWidthFont: true)
        }
        return TitleValueTableViewCell.Cell(title: lang(key: "Secret"), value: secret, useFixedWidthFont: true)
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
