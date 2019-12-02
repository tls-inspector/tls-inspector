import UIKit
import CertificateKit

class CertificateChainTableViewController: UITableViewController {

    var certificateChain: CKCertificateChain!
    var serverInfo: CKServerInfo!
    
    static func present(viewController: UIViewController, certificateChain: CKCertificateChain, serverInfo: CKServerInfo) {
        guard let controller = viewController.storyboard?.instantiateViewController(withIdentifier: "CertificateChain") as? CertificateChainTableViewController else {
            return
        }
        
        controller.certificateChain = certificateChain
        controller.serverInfo = serverInfo
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        if #available(iOS 12, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        viewController.present(navigationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.certificateChain.domain
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.certificateChain.certificates.count
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return self.serverInfo.securityHeaders.count + 1
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
            let certificate = self.certificateChain.certificates[indexPath.row]
            cell.textLabel?.text = certificate.summary
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                return TitleValueTableViewCell.Cell(title: "Negotiated Ciphersuite", value: self.certificateChain.cipherSuite, useFixedWidthFont: true)
            } else if indexPath.row == 1 {
                return TitleValueTableViewCell.Cell(title: "Negotiated Version", value: self.certificateChain.protocol, useFixedWidthFont: false)
            } else if indexPath.row == 2 {
                return TitleValueTableViewCell.Cell(title: "Remote Address", value: self.certificateChain.remoteAddress, useFixedWidthFont: true)
            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Certificates"
        } else if section == 1 {
            return "Connection Information"
        } else if section == 2 {
            return "Security HTTP Headers"
        }
        
        return ""
    }
}
