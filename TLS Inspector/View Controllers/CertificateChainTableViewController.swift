import UIKit
import CertificateKit
import SafariServices

class CertificateChainTableViewController: UITableViewController {

    var certificateChain: CKCertificateChain?
    var httpServerInfo: CKHTTPServerInfo?
    var securityHeadersSorted: [String]?

    let certificatesSectionTag = 1
    let connectionSectionTag = 2
    let redirectSectionTag = 3
    let headersSectionTag = 4

    var sections: [TableViewSection] = []

    @IBOutlet weak var trustView: UIView!
    @IBOutlet weak var trustIconLabel: UILabel!
    @IBOutlet weak var trustResultLabel: UILabel!
    @IBOutlet weak var trustDetailsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.certificateChain = CERTIFICATE_CHAIN
        self.httpServerInfo = HTTP_SERVER_INFO

        if self.certificateChain != nil {
            self.title = self.certificateChain!.domain
            self.buildTrustHeader()
        }

        buildTable()
    }

    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: VIEW_CLOSE_NOTIFICATION, object: nil)
        }
    }

    @IBAction func actionButton(_ sender: UIBarButtonItem) {
        guard let chain = self.certificateChain else { return }

        var items = [
            lang(key: "Share Certificate Chain")
        ]
        if #available(iOS 12, *) {
            items.append(lang(key: "View on SSL Labs"))
            items.append(lang(key: "Search on Shodan"))
            items.append(lang(key: "Search on crt.sh"))
        }

        UIHelper(self).presentActionSheet(target: ActionTipTarget(barButtonItem: sender),
                                          title: self.certificateChain?.domain,
                                          subtitle: nil,
                                          items: items)
        { (index) in
            if index == 0 {
                self.shareCertificateChain(sender)
            } else if index == 1 {
                self.openURL("https://www.ssllabs.com/ssltest/analyze.html?d=" + chain.domain + "&hideResults=on")
            } else if index == 2 {
                self.openURL("https://www.shodan.io/host/" + chain.remoteAddress.full)
            } else if index == 3 {
                self.openURL("https://crt.sh/?q=" + chain.domain)
            }
        }
    }

    func shareCertificateChain(_ sender: UIBarButtonItem) {
        guard let certificates = self.certificateChain?.certificates else { return }

        let pemChain = NSMutableData()
        for certificate in certificates {
            guard let pem = certificate.publicKeyAsPEM else { return }
            pemChain.append(pem)
        }

        let fileName = (self.certificateChain?.domain ?? "chain") + ".pem"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do {
            try pemChain.write(to: fileURL)
        } catch {
            UIHelper(self).presentError(error: error, dismissed: nil)
            return
        }
        let activityController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        ActionTipTarget(barButtonItem: sender).attach(to: activityController.popoverPresentationController)
        self.present(activityController, animated: true, completion: nil)
    }

    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        self.present(SFSafariViewController(url: url), animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChainSCTSegue" {
            guard let destination = segue.destination as? CertificateTimestampsTableViewController else { return }
            destination.timestamps = self.certificateChain?.signedTimestamps ?? []
        }
    }

    func buildTrustHeader() {
        let parameters = TrustBannerParameters(trust: self.certificateChain!.trustStatus)
        if parameters.solid {
            self.trustView.backgroundColor = parameters.color
        } else {
            self.trustView.backgroundColor = nil
            self.trustView.layer.borderColor = parameters.color.cgColor
            self.trustView.layer.borderWidth = 2.0
        }
        self.trustView.layer.cornerRadius = parameters.cornerRadius
        self.trustResultLabel.textColor = parameters.textColor
        self.trustResultLabel.text = parameters.text
        self.trustIconLabel.textColor = parameters.textColor
        self.trustIconLabel.font = parameters.icon.font(size: self.trustIconLabel.font.pointSize)
        self.trustIconLabel.text = parameters.icon.string()
        self.trustDetailsButton.tintColor = parameters.textColor
    }

    func buildTable() {
        self.sections = []

        self.sections.maybeAppend(makeCertificateSection())
        self.sections.maybeAppend(makeConnectionInfoSection())
        self.sections.maybeAppend(makeRedirectSection())
        self.sections.maybeAppend(makeHeadersSection())

        self.tableView.reloadData()
    }

    func makeCertificateSection() -> TableViewSection? {
        let certificateSection = TableViewSection()
        certificateSection.title = lang(key: "Certificates")
        certificateSection.tag = certificatesSectionTag

        guard let certificates = self.certificateChain?.certificates else { return nil }

        for certificate in certificates {
            guard let cell = TableViewCell.from(tableView.dequeueReusableCell(withIdentifier: "Basic")) else { return nil }

            if certificate.isExpired {
                cell.cell.textLabel?.text = lang(key: "{commonName} (Expired)", args: [certificate.summary])
                cell.cell.textLabel?.textColor = UIColor.systemRed
            } else if certificate.isNotYetValid {
                cell.cell.textLabel?.text = lang(key: "{commonName} (Not Yet Valid)", args: [certificate.summary])
                cell.cell.textLabel?.textColor = UIColor.systemRed
            } else if certificate.revoked.isRevoked {
                cell.cell.textLabel?.text = lang(key: "{commonName} (Revoked)", args: [certificate.summary])
                cell.cell.textLabel?.textColor = UIColor.systemRed
            } else {
                cell.cell.textLabel?.text = certificate.summary
            }

            certificateSection.cells.append(cell)
        }

        return certificateSection
    }

    func makeConnectionInfoSection() -> TableViewSection? {
        let connectionSection = TableViewSection()
        connectionSection.title = lang(key: "Connection Information")
        connectionSection.tag = connectionSectionTag
        if let serverError = SERVER_ERROR {
            connectionSection.footer = lang(key: "server_error_footer", args: [serverError.localizedDescription])
        }

        guard let chain = self.certificateChain else { return nil }

        connectionSection.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Negotiated Ciphersuite"),
                                                                    value: chain.cipherSuite,
                                                                    useFixedWidthFont: true))
        connectionSection.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Negotiated Version"),
                                                                    value: chain.protocol,
                                                                    useFixedWidthFont: false))
        connectionSection.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Remote Address"),
                                                                    value: chain.remoteAddress.address,
                                                                    useFixedWidthFont: true))

        if chain.keyLog != nil {
            guard let cell = TableViewCell.from(tableView.dequeueReusableCell(withIdentifier: "Basic")) else { return nil }
            cell.cell.textLabel?.text = lang(key: "View Keying Material")
            cell.didSelect = { (_, _) in
                guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "Keying") else { return }
                SPLIT_VIEW_CONTROLLER?.showDetailViewController(controller, sender: nil)
            }
            connectionSection.cells.append(cell)
        }

        let timestamps = chain.signedTimestamps ?? []
        if timestamps.count > 0 {
            guard let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Count")) else { return nil }
            guard let label = cell.cell.viewWithTag(1) as? UILabel else { return nil }
            guard let count = cell.cell.viewWithTag(2) as? UILabel else { return nil }
            label.text = lang(key: "Certificate Timestamps")
            count.text = String.init(format: "%ld", timestamps.count)
            cell.didSelect = { (_, _) in
                self.performSegue(withIdentifier: "ChainSCTSegue", sender: nil)
            }
            connectionSection.cells.append(cell)
        }

        return connectionSection
    }

    func makeRedirectSection() -> TableViewSection? {
        guard let redirectedTo = self.httpServerInfo?.redirectedTo?.host else { return nil }

        let redirectSection = TableViewSection()
        redirectSection.tag = redirectSectionTag
        let cell = TitleValueTableViewCell.Cell(title: lang(key: "Server Redirected To"), value: redirectedTo, useFixedWidthFont: true)

        // Only make the redirect cell tappable if we can actually reload
        // (which we can't do in the extension)
        if !IsExtension() {
            cell.cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            cell.cell.selectionStyle = UITableViewCell.SelectionStyle.default
        }

        redirectSection.cells.append(cell)
        return redirectSection
    }

    func makeHeadersSection() -> TableViewSection? {
        let headersSection = TableViewSection()
        headersSection.title = lang(key: "Security HTTP Headers")
        headersSection.tag = headersSectionTag

        guard let serverInfo = self.httpServerInfo else { return nil }

        for header in serverInfo.securityHeaders.keys.sorted() {
            guard let cell = TableViewCell.from(tableView.dequeueReusableCell(withIdentifier: "Icon")) else { return nil }
            guard let titleLabel = cell.cell.viewWithTag(1) as? UILabel else { return nil }
            guard let iconLabel = cell.cell.viewWithTag(2) as? UILabel else { return nil }
            titleLabel.text = header
            let hasHeader = (self.httpServerInfo?.securityHeaders[header] ?? nil) is String

            let icon = hasHeader ? FAIcon.FACheckCircleRegular : FAIcon.FAQuestionCircleRegular
            let color = hasHeader ? UIColor.materialGreen() : UIColor.materialAmber()
            iconLabel.font = icon.font(size: iconLabel.font.pointSize)
            iconLabel.textColor = color
            iconLabel.text = icon.string()
            headersSection.cells.append(cell)
        }

        guard let cell = TableViewCell.from(tableView.dequeueReusableCell(withIdentifier: "Basic")) else { return nil }
        cell.cell.textLabel?.text = lang(key: "View All")
        headersSection.cells.append(cell)

        return headersSection
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cells[indexPath.row].cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sections[section].footer
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTag = self.sections[indexPath.section].tag

        if sectionTag == certificatesSectionTag {
            CURRENT_CERTIFICATE = indexPath.row
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "Certificate") else { return }
            SPLIT_VIEW_CONTROLLER?.showDetailViewController(controller, sender: nil)
        } else if sectionTag == connectionSectionTag {
            let cell = self.sections[indexPath.section].cells[indexPath.row]
            if let didSelect = cell.didSelect {
                didSelect(tableView, indexPath)
            }
        } else if sectionTag == redirectSectionTag {
            guard let controller = reloadInspectionTarget else { return }
            guard let redirectedTo = self.httpServerInfo?.redirectedTo?.absoluteString else { return }

            controller.reloadWithQuery(query: redirectedTo)
        } else if sectionTag == headersSectionTag && indexPath.row == self.sections[indexPath.section].cells.count-1 {
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "Headers") else { return }
            SPLIT_VIEW_CONTROLLER?.showDetailViewController(controller, sender: nil)
        }
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
