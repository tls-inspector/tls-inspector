import UIKit
import CertificateKit

class CertificateTableViewController: UITableViewController {
    var certificate: CKCertificate!
    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        guard let certificate = CERTIFICATE_CHAIN?.certificates[CURRENT_CERTIFICATE] else {
            self.dismiss(animated: false, completion: nil)
            return
        }

        self.certificate = certificate
        
        self.title = self.certificate.summary

        if let subjectSection = makeNameSection(name: self.certificate.subject) {
            subjectSection.title = Lang(key: "Subject")
            self.sections.append(subjectSection)
        }
        
        if let issuerSection = makeNameSection(name: self.certificate.issuer) {
            issuerSection.title = Lang(key: "Issuer")
            self.sections.append(issuerSection)
        }
        
        if let validityPeriodSection = makeValidityPeriodSection() {
            self.sections.append(validityPeriodSection)
        }
        
        if let keyUsageSection = makeKeyUsageSection() {
            self.sections.append(keyUsageSection)
        }
        
        if let featureSection = makeFeatureSection() {
            self.sections.append(featureSection)
        }
        
        if let fingerprintsSection = makeFingerprintsSection() {
            self.sections.append(fingerprintsSection)
        }
        
        super.viewDidLoad()
    }
    
    func makeNameSection(name: CKNameObject) -> TableViewSection? {
        let section = TableViewSection()
        if let cn = name.commonName {
            section.cells.append(TitleValueTableViewCell.Cell(title: Lang(key: "Subject::CN"), value: cn, useFixedWidthFont: false))
        }
        if let email = name.emailAddress {
            section.cells.append(TitleValueTableViewCell.Cell(title: Lang(key: "Subject::E"), value: email, useFixedWidthFont: false))
        }
        if let org = name.organizationName {
            section.cells.append(TitleValueTableViewCell.Cell(title: Lang(key: "Subject::O"), value: org, useFixedWidthFont: false))
        }
        if let ou = name.organizationalUnitName {
            section.cells.append(TitleValueTableViewCell.Cell(title: Lang(key: "Subject::OU"), value: ou, useFixedWidthFont: false))
        }
        if let locale = name.localityName {
            section.cells.append(TitleValueTableViewCell.Cell(title: Lang(key: "Subject::L"), value: locale, useFixedWidthFont: false))
        }
        if let state = name.stateOrProvinceName {
            section.cells.append(TitleValueTableViewCell.Cell(title: Lang(key: "Subject::S"), value: state, useFixedWidthFont: false))
        }
        if let country = name.countryName {
            section.cells.append(TitleValueTableViewCell.Cell(title: Lang(key: "Subject::C"), value: Lang(key: "Country::" + country), useFixedWidthFont: false))
        }
        return section
    }
    
    func makeValidityPeriodSection() -> TableViewSection? {
        let validitySection = TableViewSection()
        validitySection.title = Lang(key: "Validity Period")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let notBefore = self.certificate.notBefore else {
            return nil
        }
        guard let notAfter = self.certificate.notAfter else {
            return nil
        }
        
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "Detail") {
            cell.detailTextLabel?.text = formatter.string(from: notBefore)
            cell.textLabel?.text = Lang(key: "Not Before")
            validitySection.cells.append(cell)
        }
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "Detail") {
            cell.detailTextLabel?.text = formatter.string(from: notAfter)
            cell.textLabel?.text = Lang(key: "Not After")
            validitySection.cells.append(cell)
        }
        
        return validitySection
    }
    
    func makeKeyUsageSection() -> TableViewSection? {
        let usageSection = TableViewSection()
        usageSection.title = Lang(key: "Key Usage")
        
        var keyUsage: [String] = []
        var extKeyUsage: [String] = []
        for usage in self.certificate.keyUsage ?? [] {
            keyUsage.append(Lang(key: "keyUsage::" + usage))
        }
        for usage in self.certificate.extendedKeyUsage ?? [] {
            extKeyUsage.append(Lang(key: "keyUsage::" + usage))
        }
        
        if keyUsage.count == 0 && extKeyUsage.count == 0 {
            return nil
        }
        
        if keyUsage.count > 0 {
            usageSection.cells.append(TitleValueTableViewCell.Cell(title: Lang(key: "Basic"), value: keyUsage.joined(separator: ", ")))
        }
        if extKeyUsage.count > 0 {
            usageSection.cells.append(TitleValueTableViewCell.Cell(title: Lang(key: "Extended"), value: extKeyUsage.joined(separator: ", ")))
        }
        
        return usageSection
    }
    
    func makeFeatureSection() -> TableViewSection? {
        let featureSection = TableViewSection()
        featureSection.title = Lang(key: "Features")
        
        guard let features = self.certificate.tlsFeatures else {
            return nil
        }
        
        for feature in features {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Basic") else {
                continue
            }
            cell.textLabel?.text = Lang(key: feature)
            featureSection.cells.append(cell)
        }
        
        if featureSection.cells.count == 0 {
            return nil
        }
        
        return featureSection
    }
    
    func makeFingerprintsSection() -> TableViewSection? {
        let fingerprintsSection = TableViewSection()
        fingerprintsSection.title = Lang(key: "Fingerprints")
        
        if UserOptions.showFingerprintMD5, let md5 = self.certificate.md5Fingerprint {
            fingerprintsSection.cells.append(TitleValueTableViewCell.Cell(title: "MD5", value: md5, useFixedWidthFont: true))
        }
        if UserOptions.showFingerprintSHA128, let s128 = self.certificate.sha1Fingerprint {
            fingerprintsSection.cells.append(TitleValueTableViewCell.Cell(title: "SHA-128", value: s128, useFixedWidthFont: true))
        }
        if UserOptions.showFingerprintSHA256, let s256 = self.certificate.sha256Fingerprint {
            fingerprintsSection.cells.append(TitleValueTableViewCell.Cell(title: "SHA-258", value: s256, useFixedWidthFont: true))
        }
        if UserOptions.showFingerprintSHA512, let s512 = self.certificate.sha512Fingerprint {
            fingerprintsSection.cells.append(TitleValueTableViewCell.Cell(title: "SHA-512", value: s512, useFixedWidthFont: true))
        }
        
        if fingerprintsSection.cells.count == 0 {
            return nil
        }
        return fingerprintsSection
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
        return self.sections[indexPath.section].cells[indexPath.row]
    }
}
