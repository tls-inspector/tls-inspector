import UIKit
import CertificateKit

class AboutTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 2
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = lang(key: "Share TLS Inspector")
        } else if indexPath.section == 0 && indexPath.row == 1 {
            cell.textLabel?.text = lang(key: "Rate in App Store")
        } else if indexPath.section == 0 && indexPath.row == 2 {
            cell.textLabel?.text = lang(key: "Provide Feedback")
        } else if indexPath.section == 1 && indexPath.row == 0 {
            cell.textLabel?.text = lang(key: "Contribute to TLS Inspector")
        } else if indexPath.section == 1 && indexPath.row == 1 {
            cell.textLabel?.text = lang(key: "Test New Features")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return lang(key: "Share & Feedback")
        } else if section == 1 {
            return lang(key: "Get Involved")
        }

        return nil
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            let info = Bundle.main.infoDictionary ?? [:]
            let appVersion: String = (info["CFBundleShortVersionString"] as? String) ?? "Unknown"
            let build: String = (info[kCFBundleVersionKey as String] as? String) ?? "Unknown"
            let opensslVersion = CertificateKit.opensslVersion() ?? "Unknown"
            let libcurlVersion = CertificateKit.libcurlVersion() ?? "Unknown"
            return "App: \(appVersion) (\(build)), OpenSSL: \(opensslVersion), cURL: \(libcurlVersion)"
        } else if section == 1 {
            return lang(key: "copyright_license_footer")
        }

        return nil
    }
}
