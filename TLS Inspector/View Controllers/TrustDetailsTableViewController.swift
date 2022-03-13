import UIKit
import CertificateKit

class TrustDetailsTableViewController: UITableViewController {
    @IBOutlet weak var trustView: UIView!
    @IBOutlet weak var trustIconLabel: UILabel!
    @IBOutlet weak var trustResultLabel: UILabel!
    var certificateChain: CKCertificateChain!
    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let chain = CERTIFICATE_CHAIN else {
            self.dismiss(animated: false, completion: nil)
            return
        }
        self.certificateChain = chain
        self.buildTrustHeader()

        if let section = buildTrustSection() {
            self.sections.append(section)
        }
    }

    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    func buildTrustHeader() {
        self.trustView.layer.cornerRadius = 5.0

        var trustColor = UIColor.materialPink()
        var trustText = lang(key: "Unknown")
        var trustIcon = FAIcon.FAQuestionCircleSolid
        switch self.certificateChain.trusted {
        case .trusted:
            trustColor = UIColor.materialGreen()
            trustText = lang(key: "Trusted")
            trustIcon = FAIcon.FACheckCircleSolid
        case .locallyTrusted:
            trustColor = UIColor.materialLightGreen()
            trustText = lang(key: "Locally Trusted")
            trustIcon = FAIcon.FACheckCircleRegular
        case .untrusted, .invalidDate, .wrongHost:
            trustColor = UIColor.materialAmber()
            trustText = lang(key: "Untrusted")
            trustIcon = FAIcon.FAExclamationCircleSolid
        case .sha1Leaf, .sha1Intermediate:
            trustColor = UIColor.materialRed()
            trustText = lang(key: "Insecure")
            trustIcon = FAIcon.FATimesCircleSolid
        case .selfSigned, .revokedLeaf, .revokedIntermediate:
            trustColor = UIColor.materialRed()
            trustText = lang(key: "Untrusted")
            trustIcon = FAIcon.FATimesCircleSolid
        case .leafMissingRequiredKeyUsage:
            trustColor = UIColor.materialAmber()
            trustText = lang(key: "Untrusted")
            trustIcon = FAIcon.FAExclamationCircleSolid
        case .weakRSAKey:
            trustColor = UIColor.materialRed()
            trustText = lang(key: "Insecure")
            trustIcon = FAIcon.FATimesCircleSolid
        case .issueDateTooLong:
            trustColor = UIColor.materialAmber()
            trustText = lang(key: "Untrusted")
            trustIcon = FAIcon.FAExclamationCircleSolid
        case .badAuthority:
            trustColor = UIColor.materialRed(level: 900) ?? UIColor.materialRed()
            trustText = lang(key: "Dangerous")
            trustIcon = FAIcon.FAExclamationTriangleSolid
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

    // swiftlint:disable cyclomatic_complexity
    func buildTrustSection() -> TableViewSection? {
        let trustSection = TableViewSection()
        trustSection.title = lang(key: "Trust Details")
        var explanation = ""
        var isSecure = ""

        switch self.certificateChain.trusted {
        case .trusted:
            explanation = lang(key: "explanation::trust")
            isSecure = lang(key: "secure::trust")
        case .locallyTrusted:
            explanation = lang(key: "explanation::local_trust")
            isSecure = lang(key: "secure::local_trust")
        case .untrusted:
            explanation = lang(key: "explanation::untrusted")
            isSecure = lang(key: "secure::untrusted")
        case .invalidDate:
            explanation = lang(key: "explanation::invalid_date")
            isSecure = lang(key: "secure::invalid_date")
        case .wrongHost:
            explanation = lang(key: "explanation::wrong_host")
            isSecure = lang(key: "secure::wrong_host")
        case .sha1Leaf:
            explanation = lang(key: "explanation::sha1_leaf")
            isSecure = lang(key: "secure::sha1_leaf")
        case .sha1Intermediate:
            explanation = lang(key: "explanation::sha1_int")
            isSecure = lang(key: "secure::sha1_int")
        case .selfSigned:
            explanation = lang(key: "explanation::self_signed")
            isSecure = lang(key: "secure::self_signed")
        case .revokedLeaf:
            explanation = lang(key: "explanation::revoked")
            isSecure = lang(key: "secure::revoked")
        case .revokedIntermediate:
            explanation = lang(key: "explanation::revoked")
            isSecure = lang(key: "secure::revoked")
        case .leafMissingRequiredKeyUsage:
            explanation = lang(key: "explanation::leaf_keyusage")
            isSecure = lang(key: "secure::leaf_keyusage")
        case .weakRSAKey:
            explanation = lang(key: "explanation::weak_rsa")
            isSecure = lang(key: "secure::weak_rsa")
        case .issueDateTooLong:
            explanation = lang(key: "explanation::issue_date_too_long")
            isSecure = lang(key: "secure::issue_date_too_long")
        case .badAuthority:
            explanation = lang(key: "explanation::bad_authority")
            isSecure = lang(key: "secure::bad_authority")
        @unknown default:
            explanation = lang(key: "Unknown")
            isSecure = lang(key: "Unknown")
        }

        trustSection.cells.append(TitleValueTableViewCell.Cell(title:
            lang(key: "What does this mean?"), value: explanation))
        trustSection.cells.append(TitleValueTableViewCell.Cell(title:
            lang(key: "Is the connection to this site secure?"), value: isSecure))

        return trustSection
    }
    // swiftlint:enable cyclomatic_complexity

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
        return self.sections[indexPath.section].cells[indexPath.row]
    }
}
