import UIKit
import CertificateKit
import SafariServices

class CertificateTableViewController: UITableViewController {
    var certificate: CKCertificate!
    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildTable()
    }

    @IBAction func actionButton(_ sender: UIBarButtonItem) {
        var items = [
            lang(key: "Share Certificate"),
            lang(key: "Add Certificate Expiry Reminder")
        ]
        if #available(iOS 15, *) {
            items.append(lang(key: "Show Certificate on crt.sh"))
        }

        UIHelper(self).presentActionSheet(target: ActionTipTarget(barButtonItem: sender),
                                          title: self.certificate.summary,
                                          subtitle: nil,
                                          items: items)
        { (index) in
            if index == 0 {
                self.shareCertificate(sender)
            } else if index == 1 {
                self.addCertificateReminder(sender)
            } else if index == 2 {
                self.openURL("https://crt.sh/?q=" + (self.certificate.sha256Fingerprint ?? ""))
            }
        }
    }

    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        self.present(SFSafariViewController(url: url), animated: true, completion: nil)
    }

    func addCertificateReminder(_ sender: UIBarButtonItem) {
        guard let chain = CERTIFICATE_CHAIN else { return }

        UIHelper(self).presentActionSheet(target: ActionTipTarget(barButtonItem: sender),
                                          title: lang(key: "Notification Date"),
                                          subtitle: lang(key: "How soon before the certificate expires should we notify you?"),
                                          items: [
                                            lang(key: "2 weeks"),
                                            lang(key: "1 month"),
                                            lang(key: "3 months"),
                                            lang(key: "6 months"),
                                        ])
        { (index) in
            if index < 0 {
                return
            }

            var days = 0
            if index == 0 {
                days = 2 * 7
            } else if index == 1 {
                days = 30
            } else if index == 2 {
                days = 30 * 3
            } else if index == 3 {
                days = 30 * 6
            }
            CertificateReminder.addReminder(certificate: self.certificate,
                                            domain: chain.domain,
                                            daysBeforeExpire: days)
            { (rerror) in
                if let error = rerror {
                    UIHelper(self).presentError(error: error, dismissed: nil)
                } else {
                    UIHelper(self).presentAlert(title: lang(key: "Reminder Added"),
                                                body: lang(key: "Use the Reminders app to customize the reminder"),
                                                dismissed: nil)
                }
            }
        }
    }

    func shareCertificate(_ sender: UIBarButtonItem) {
        guard let pem = self.certificate.publicKeyAsPEM else {
            UIHelper(self).presentAlert(title: lang(key: "Unable to export certificate"),
                                        body: lang(key: "We were unable to export the certificate in PEM format."),
                                        dismissed: nil)
            return
        }

        let fileName = (self.certificate.serialNumber ?? "certificate") + ".pem"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do {
            try pem.write(to: fileURL)
        } catch {
            UIHelper(self).presentError(error: error, dismissed: nil)
            return
        }
        let activityController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        ActionTipTarget(barButtonItem: sender).attach(to: activityController.popoverPresentationController)
        self.present(activityController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CertSCTSegue" {
            guard let destination = segue.destination as? CertificateTimestampsTableViewController else { return }
            destination.timestamps = self.certificate.signedTimestamps ?? []
        }
    }

    func buildTable() {
        guard let certificate = CERTIFICATE_CHAIN?.certificates[CURRENT_CERTIFICATE] else { return }

        self.sections = []
        self.certificate = certificate
        self.title = self.certificate.summary
        self.sections.maybeAppend(makeSubjectNameSection())
        self.sections.maybeAppend(makeIssuerNameSection())
        self.sections.maybeAppend(makeValidityPeriodSection())
        self.sections.maybeAppend(makeKeyUsageSection())
        self.sections.maybeAppend(makeFeatureSection())
        self.sections.maybeAppend(makePublicKeySection())
        self.sections.maybeAppend(makeFingerprintsSection())
        self.sections.maybeAppend(makeKeyIdentifierSection())
        self.sections.maybeAppend(makeStatusProvidersSection())
        self.sections.maybeAppend(makeMetadataSection())
        self.sections.maybeAppend(makeExtensionsSection())
        self.sections.maybeAppend(makeVendorTrustStatusSection())

        self.tableView.reloadData()
    }

    func makeSubjectNameSection() -> TableViewSection? {
        guard let section = makeNameSection(name: self.certificate.subject) else { return nil }
        section.title = lang(key: "Subject")
        let alternateNames = self.certificate.alternateNames ?? []
        if alternateNames.count > 0 {
            guard let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Count")) else { return nil }
            guard let label = cell.cell.viewWithTag(1) as? UILabel else { return nil }
            guard let count = cell.cell.viewWithTag(2) as? UILabel else { return nil }
            label.text = lang(key: "Alternate Names")
            count.text = String.init(format: "%ld", alternateNames.count)
            cell.didSelect = { (_, _) in
                self.performSegue(withIdentifier: "SANSUNDERTALE", sender: nil)
            }
            section.cells.append(cell)
        }
        return section
    }

    func makeIssuerNameSection() -> TableViewSection? {
        guard let section = makeNameSection(name: self.certificate.issuer) else { return nil }
        section.title = lang(key: "Issuer")
        return section
    }

    func makeNameSection(name: CKNameObject) -> TableViewSection? {
        let section = TableViewSection()
        for cn in name.commonNames {
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Subject::CN"),
                                                              value: cn,
                                                              useFixedWidthFont: false))
        }
        for country in name.countryCodes {
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Subject::C"),
                                                              value: lang(key: "Country::" + country),
                                                              useFixedWidthFont: false))
        }
        for city in name.cities {
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Subject::L"),
                                                              value: city,
                                                              useFixedWidthFont: false))
        }
        for state in name.states {
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Subject::S"),
                                                              value: state,
                                                              useFixedWidthFont: false))
        }
        for org in name.organizations {
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Subject::O"),
                                                              value: org,
                                                              useFixedWidthFont: false))
        }
        for ou in name.organizationalUnits {
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Subject::OU"),
                                                              value: ou,
                                                              useFixedWidthFont: false))
        }
        for email in name.emailAddresses {
            section.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Subject::E"),
                                                              value: email,
                                                              useFixedWidthFont: false))
        }
        return section
    }

    func makeValidityPeriodSection() -> TableViewSection? {
        let validitySection = TableViewSection()
        validitySection.title = lang(key: "Validity Period")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm 'UTC'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let notBefore = self.certificate.notBefore else { return nil }
        guard let notAfter = self.certificate.notAfter else { return nil }

        if let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Detail")) {
            cell.cell.detailTextLabel?.text = formatter.string(from: notBefore)
            cell.cell.textLabel?.text = lang(key: "Not Before")
            validitySection.cells.append(cell)
        }
        if let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Detail")) {
            cell.cell.detailTextLabel?.text = formatter.string(from: notAfter)
            cell.cell.textLabel?.text = lang(key: "Not After")
            validitySection.cells.append(cell)
        }
        if let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Detail")) {
            cell.cell.detailTextLabel?.text = DateDuration.between(first: notBefore, second: notAfter)
            cell.cell.textLabel?.text = lang(key: "Valid For")
            validitySection.cells.append(cell)
        }
        if let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Detail")) {
            cell.cell.detailTextLabel?.text = DateDuration.between(first: Date(), second: notAfter)
            cell.cell.textLabel?.text = lang(key: "Will Expire In")
            validitySection.cells.append(cell)
        }

        return validitySection
    }

    func makeKeyUsageSection() -> TableViewSection? {
        let usageSection = TableViewSection()
        usageSection.title = lang(key: "Key Usage")

        var keyUsage: [String] = []
        var extKeyUsage: [String] = []
        for usage in self.certificate.keyUsage ?? [] {
            keyUsage.append(lang(key: "keyUsage::" + usage))
        }
        for usage in self.certificate.extendedKeyUsage ?? [] {
            extKeyUsage.append(lang(key: "keyUsage::" + usage))
        }

        if keyUsage.count == 0 && extKeyUsage.count == 0 {
            return nil
        }

        if keyUsage.count > 0 {
            usageSection.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Basic"),
                                                                   value: keyUsage.joined(separator: ", ")))
        }
        if extKeyUsage.count > 0 {
            usageSection.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Extended"),
                                                                   value: extKeyUsage.joined(separator: ", ")))
        }

        return usageSection
    }

    func makeFeatureSection() -> TableViewSection? {
        let featureSection = TableViewSection()
        featureSection.title = lang(key: "Features")

        guard let features = self.certificate.tlsFeatures else { return nil }

        for feature in features {
            guard let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Basic")) else {
                continue
            }
            cell.cell.textLabel?.text = lang(key: feature)
            featureSection.cells.append(cell)
        }

        if featureSection.cells.count == 0 {
            return nil
        }

        return featureSection
    }

    func makeFingerprintsSection() -> TableViewSection? {
        let fingerprintsSection = TableViewSection()
        fingerprintsSection.title = lang(key: "Fingerprints")

        if UserOptions.showFingerprintMD5, let md5 = self.certificate.md5Fingerprint {
            fingerprintsSection.cells.append(TitleValueTableViewCell.Cell(title: "MD5",
                                                                          value: md5,
                                                                          useFixedWidthFont: true))
        }
        if UserOptions.showFingerprintSHA128, let s128 = self.certificate.sha1Fingerprint {
            fingerprintsSection.cells.append(TitleValueTableViewCell.Cell(title: "SHA1",
                                                                          value: s128,
                                                                          useFixedWidthFont: true))
        }
        if UserOptions.showFingerprintSHA256, let s256 = self.certificate.sha256Fingerprint {
            fingerprintsSection.cells.append(TitleValueTableViewCell.Cell(title: "SHA-256",
                                                                          value: s256,
                                                                          useFixedWidthFont: true))
        }
        if UserOptions.showFingerprintSHA512, let s512 = self.certificate.sha512Fingerprint {
            fingerprintsSection.cells.append(TitleValueTableViewCell.Cell(title: "SHA-512",
                                                                          value: s512,
                                                                          useFixedWidthFont: true))
        }

        if fingerprintsSection.cells.count == 0 {
            return nil
        }
        return fingerprintsSection
    }

    func makePublicKeySection() -> TableViewSection? {
        let pubKeySection = TableViewSection()
        pubKeySection.title = lang(key: "Public Key")

        guard let publicKey = self.certificate.publicKey else { return nil }

        guard let algorithmCell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Detail")) else { return nil }
        algorithmCell.cell.textLabel?.text = lang(key: "Algorithm")
        algorithmCell.cell.detailTextLabel?.text = lang(key: "KeyAlgorithm::" + publicKey.algroithm)
        pubKeySection.cells.append(algorithmCell)

        guard let signatureCell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Detail")) else { return nil }
        signatureCell.cell.textLabel?.text = lang(key: "Signature")
        signatureCell.cell.detailTextLabel?.text = self.certificate.signatureAlgorithm ?? "Unknown"
        pubKeySection.cells.append(signatureCell)

        guard let sizeCell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Detail")) else { return nil }
        sizeCell.cell.textLabel?.text = lang(key: "Size")
        sizeCell.cell.detailTextLabel?.text = String.init(format: "%ld", publicKey.bitLength)
        pubKeySection.cells.append(sizeCell)

        return pubKeySection
    }

    func makeKeyIdentifierSection() -> TableViewSection? {
        let keyIdentifierSection = TableViewSection()
        keyIdentifierSection.title = lang(key: "Key Identifier")

        guard let identifiers = self.certificate.keyIdentifiers else { return nil }

        if let subject = identifiers["subject"] {
            keyIdentifierSection.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Subject"),
                                                                           value: subject,
                                                                           useFixedWidthFont: true))
        }

        if let authority = identifiers["authority"] {
            keyIdentifierSection.cells.append(TitleValueTableViewCell.Cell(title: lang(key: "Authority"),
                                                                           value: authority,
                                                                           useFixedWidthFont: true))
        }

        if keyIdentifierSection.cells.count == 0 {
            return nil
        }
        return keyIdentifierSection
    }

    func makeStatusProvidersSection() -> TableViewSection? {
        let providersSection = TableViewSection()
        providersSection.title = lang(key: "Status Providers")

        if let crls = self.certificate.crlDistributionPoints {
            for crl_url in crls {
                providersSection.cells.append(TitleValueTableViewCell.Cell(title: "CRL",
                                                                           value: crl_url.absoluteString,
                                                                           useFixedWidthFont: true))
            }
        }

        if let ocspURL = self.certificate.ocspURL {
            providersSection.cells.append(TitleValueTableViewCell.Cell(title: "OCSP",
                                                                       value: ocspURL.absoluteString,
                                                                       useFixedWidthFont: true))
        }

        if providersSection.cells.count == 0 {
            return nil
        }
        return providersSection
    }

    func makeMetadataSection() -> TableViewSection? {
        let metadataSection = TableViewSection()
        metadataSection.title = lang(key: "Metadata")

        if let serial = self.certificate.serialNumber {
            metadataSection.cells.append(TitleValueTableViewCell.Cell(title: "Serial Number",
                                                                      value: serial,
                                                                      useFixedWidthFont: true))
        }

        if let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Detail")) {
            cell.cell.textLabel?.text = lang(key: "Certificate Authority")
            cell.cell.detailTextLabel?.text = self.certificate.isCA ? lang(key: "Yes") : lang(key: "No")
            metadataSection.cells.append(cell)
        }

        if let version = self.certificate.version {
            guard let versionCell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Detail")) else { return nil }
            versionCell.cell.textLabel?.text = lang(key: "Version")
            versionCell.cell.detailTextLabel?.text = version.stringValue
            metadataSection.cells.append(versionCell)
        }

        let timestamps = self.certificate.signedTimestamps ?? []
        if timestamps.count > 0 {
            guard let cell = TableViewCell.from(self.tableView.dequeueReusableCell(withIdentifier: "Count")) else { return nil }
            guard let label = cell.cell.viewWithTag(1) as? UILabel else { return nil }
            guard let count = cell.cell.viewWithTag(2) as? UILabel else { return nil }
            label.text = lang(key: "Certificate Timestamps")
            count.text = String.init(format: "%ld", timestamps.count)
            cell.didSelect = { (_, _) in
                self.performSegue(withIdentifier: "CertSCTSegue", sender: nil)
            }
            metadataSection.cells.append(cell)
        }

        if metadataSection.cells.count == 0 {
            return nil
        }
        return metadataSection
    }

    func makeExtensionsSection() -> TableViewSection? {
        let extensionsSection = TableViewSection()
        extensionsSection.title = lang(key: "Extensions")

        for ext in certificate.extraExtensions ?? [] {
            let title = ext.critical ? lang(key: "{oid} (Critical)", args: [ext.oid]) : ext.oid
            var fixedWith = false

            var value = "(unknown)"
            switch ext.valueType {
            case .string:
                value = ext.stringValue() ?? "(null)"
                fixedWith = true
            case .boolean:
                value = ext.boolValue() ? "True" : "False"
            case .number:
                value = "\(ext.integerValue())"
            case .date:
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm 'UTC'"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                if let date = ext.dateValue() {
                    value = formatter.string(from: date)
                } else {
                    value = "(null)"
                }
            case .unknown:
                value = ext.hexString()
                fixedWith = true
            @unknown default:
                break
            }
            let cell = TitleValueTableViewCell.Cell(title: title, value: value, useFixedWidthFont: fixedWith)
            extensionsSection.cells.append(cell)
        }

        if extensionsSection.cells.count == 0 {
            return nil
        }
        return extensionsSection
    }

    func makeVendorTrustStatusSection() -> TableViewSection? {
        let vendorTrustSection = TableViewSection()
        vendorTrustSection.title = lang(key: "Certificate Trust")

        guard let vendorTrustStatus = self.certificate.vendorTrustStatus else {
            return nil
        }

        for key in ["apple", "google", "microsoft", "mozilla"] {
            let isTrusted = vendorTrustStatus[key] as? Bool ?? false
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Status") else {
                continue
            }
            guard let iconLabel = cell.viewWithTag(1) as? UILabel else {
                continue
            }
            let icon = isTrusted ? FAIcon.FACheckCircleRegular : FAIcon.FATimesCircleRegular
            iconLabel.text = icon.string()
            iconLabel.font = icon.font(size: iconLabel.font.pointSize)
            iconLabel.textColor = isTrusted ? UIColor.materialGreen() : UIColor.materialRed()
            guard let statusLabel = cell.viewWithTag(2) as? UILabel else {
                continue
            }
            statusLabel.text = lang(key: key)
            vendorTrustSection.cells.append(TableViewCell(cell))
        }

        return vendorTrustSection
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cells[indexPath.row].cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.sections[indexPath.section].cells[indexPath.row]
        guard let didSelect = cell.didSelect else { return }
        didSelect(tableView, indexPath)
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
