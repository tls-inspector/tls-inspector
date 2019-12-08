import UIKit
import CertificateKit

class CertificateChainTableViewController: UITableViewController {

    var certificateChain: CKCertificateChain?
    var serverInfo: CKServerInfo?
    var securityHeadersSorted: [String]?

    @IBOutlet weak var trustView: UIView!
    @IBOutlet weak var trustIconLabel: UILabel!
    @IBOutlet weak var trustResultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.certificateChain = CERTIFICATE_CHAIN
        self.serverInfo = SERVER_INFO
        
        if self.certificateChain != nil {
            self.title = self.certificateChain!.domain
            self.buildTrustHeader()
        }
        
        if let serverInfo = self.serverInfo {
            self.securityHeadersSorted = serverInfo.securityHeaders.keys.sorted()
        }
    }
    
    func buildTrustHeader() {
        self.trustView.layer.cornerRadius = 5.0
        
        var trustColor = UIColor.materialPink()
        var trustText = Lang(key: "Unknown")
        var trustIcon = FAIcon.FAQuestionCircleSolid
        switch (self.certificateChain!.trusted) {
        case .trusted:
            trustColor = UIColor.materialGreen()
            trustText = Lang(key: "Trusted")
            trustIcon = FAIcon.FACheckCircleSolid
            break
        case .locallyTrusted:
            trustColor = UIColor.materialLightGreen()
            trustText = Lang(key: "Locally Trusted")
            trustIcon = FAIcon.FACheckCircleRegular
            break
        case .untrusted, .invalidDate, .wrongHost:
            trustColor = UIColor.materialAmber()
            trustText = Lang(key: "Untrusted")
            trustIcon = FAIcon.FAExclamationCircleSolid
            break
        case .sha1Leaf, .sha1Intermediate:
            trustColor = UIColor.materialRed()
            trustText = Lang(key: "Insecure")
            trustIcon = FAIcon.FATimesCircleSolid
            break
        case .selfSigned, .revokedLeaf, .revokedIntermediate:
            trustColor = UIColor.materialRed()
            trustText = Lang(key: "Untrusted")
            trustIcon = FAIcon.FATimesCircleSolid
            break
        @unknown default:
            // Default already set
            break
        }
        
        self.trustView.backgroundColor = trustColor
        self.trustResultLabel.textColor = UIColor.white
        self.trustResultLabel.text = trustText
        self.trustIconLabel.textColor = UIColor.white
        self.trustIconLabel.font = trustIcon.font(size: self.trustIconLabel.font.pointSize)
        self.trustIconLabel.text = trustIcon.string()
    }

    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.certificateChain == nil {
            return 0
        }
        var count = 2
        if self.securityHeadersSorted != nil {
            count += 1
        }
        return count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.certificateChain!.certificates.count
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return self.securityHeadersSorted!.count + 1
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
            let certificate = self.certificateChain!.certificates[indexPath.row]
            cell.textLabel?.text = certificate.summary
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                return TitleValueTableViewCell.Cell(title: Lang(key: "Negotiated Ciphersuite"), value: self.certificateChain!.cipherSuite, useFixedWidthFont: true)
            } else if indexPath.row == 1 {
                return TitleValueTableViewCell.Cell(title: Lang(key: "Negotiated Version"), value: self.certificateChain!.protocol, useFixedWidthFont: false)
            } else if indexPath.row == 2 {
                return TitleValueTableViewCell.Cell(title: Lang(key: "Remote Address"), value: self.certificateChain!.remoteAddress, useFixedWidthFont: true)
            }
        } else if indexPath.section == 2 {
            if indexPath.row >= self.securityHeadersSorted!.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
                cell.textLabel?.text = Lang(key: "View All")
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Icon", for: indexPath)
            guard let titleLabel = cell.viewWithTag(1) as? UILabel else {
                return cell
            }
            guard let iconLabel = cell.viewWithTag(2) as? UILabel else {
                return cell
            }
            let key = securityHeadersSorted![indexPath.row]
            titleLabel.text = key
            guard let value = self.serverInfo?.securityHeaders[key] else {
                return cell
            }
            if value is String {
                iconLabel.text = FAIcon.FACheckCircleSolid.string()
                iconLabel.textColor = UIColor.materialGreen()
            } else {
                iconLabel.text = FAIcon.FATimesCircleSolid.string()
                iconLabel.textColor = UIColor.materialRed()
            }
            
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Lang(key: "Certificates")
        } else if section == 1 {
            return Lang(key: "Connection Information")
        } else if section == 2 {
            return Lang(key: "Security HTTP Headers")
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            CURRENT_CERTIFICATE = indexPath.row
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "Certificate") else {
                return
            }
            SPLIT_VIEW_CONTROLLER?.showDetailViewController(controller, sender: nil)
        }
    }
}
