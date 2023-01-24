import UIKit
import CertificateKit

class RootCACertificatesTableViewController: UITableViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!

    var sections: [TableViewSection] = []
    var isUpdating = false
    let updateQueue = DispatchQueue(label: "UpdateQueue")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildTable()
    }

    func startUpdate() {
        self.isUpdating = true
        self.doneButton.isEnabled = false
        self.buildTable()

        // Timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            if !self.isUpdating {
                return
            }

            UIHelper(self).presentAlert(title: lang(key: "Error"), body: lang(key: "Operation timed out"), dismissed: nil)
            self.doneButton.isEnabled = true
            self.isUpdating = false
            self.buildTable()
            return
        }

        updateQueue.async {
            var updateErr: NSError?
            CKRootCACertificateBundleManager.sharedInstance().updateNow(&updateErr)
            if let error = updateErr {
                if error.code == 200 {
                    UIHelper(self).presentAlert(title: "Root CA Certificates", body: "You have the latest root CA certificate bundles", dismissed: nil)
                } else {
                    UIHelper(self).presentError(error: NewError(description: lang(key: "rootca_error")), dismissed: nil)
                }
            }
            RunOnMain {
                self.doneButton.isEnabled = true
                self.isUpdating = false
                self.buildTable()
            }
        }
    }

    func buildBundleSection(_ title: String, certificateBundle: CKCertificateBundle?) -> TableViewSection {
        let section = TableViewSection()
        section.title = title

        guard let bundle = certificateBundle else {
            return section
        }

        if let bundleDate = bundle.metadata.bundleDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
            let dateCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            dateCell.textLabel?.text = lang(key: "Bundle Date")
            dateCell.detailTextLabel?.text = formatter.string(from: bundleDate)
            section.cells.append(TableViewCell(dateCell))
        }

        if let count = bundle.metadata.certificateCount {
            let countCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            countCell.textLabel?.text = lang(key: "Certificates")
            countCell.detailTextLabel?.text = count.stringValue
            section.cells.append(TableViewCell(countCell))
        }

        if let sha256 = bundle.metadata.bundleSHA256 {
            section.cells.append(TitleValueTableViewCell.Cell(title: "SHA-256", value: sha256, useFixedWidthFont: true))
        }

        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "Status") {
            guard let iconLabel = cell.viewWithTag(1) as? UILabel else {
                return section
            }

            guard let statusLabel = cell.viewWithTag(2) as? UILabel else {
                return section
            }

            let icon = bundle.embedded ? FAIcon.FACheckCircleRegular : FAIcon.FACheckCircleSolid
            iconLabel.text = icon.string()
            iconLabel.font = icon.font(size: iconLabel.font.pointSize)
            iconLabel.textColor = UIColor.materialGreen()
            statusLabel.text = bundle.embedded ? lang(key: "Embedded") : lang(key: "Verified")

            section.cells.append(TableViewCell(cell))
        }

        return section
    }

    func buildUpdateSection() -> TableViewSection {
        let section = TableViewSection()
        section.footer = lang(key: "rootca_footer")

        if isUpdating {
            section.cells.maybeAppend(TableViewCell.from(tableView.dequeueReusableCell(withIdentifier: "Loading")))
            return section
        }

        let updateCell = TableViewCell(UITableViewCell(style: .default, reuseIdentifier: nil))
        updateCell.cell.textLabel?.text = lang(key: "Check for updates")
        updateCell.cell.textLabel?.textColor = UIColor.systemBlue
        updateCell.didSelect = { (_, _) in
            self.startUpdate()
        }
        section.cells.append(updateCell)

        if CKRootCACertificateBundleManager.sharedInstance().usingDownloadedBundles {
            let clearCell = TableViewCell(UITableViewCell(style: .default, reuseIdentifier: nil))
            clearCell.cell.textLabel?.text = lang(key: "Clear downloaded bundles")
            clearCell.cell.textLabel?.textColor = UIColor.systemRed
            clearCell.didSelect = { (_, _) in
                CKRootCACertificateBundleManager.sharedInstance().clearDownloadedBundles()
                self.buildTable()
                self.tableView.reloadData()
            }
            section.cells.append(clearCell)
        }

        return section
    }

    func buildTable() {
        self.sections = [
            self.buildBundleSection(lang(key: "apple"), certificateBundle: CKRootCACertificateBundleManager.sharedInstance().appleBundle),
            self.buildBundleSection(lang(key: "google"), certificateBundle: CKRootCACertificateBundleManager.sharedInstance().googleBundle),
            self.buildBundleSection(lang(key: "microsoft"), certificateBundle: CKRootCACertificateBundleManager.sharedInstance().microsoftBundle),
            self.buildBundleSection(lang(key: "mozilla"), certificateBundle: CKRootCACertificateBundleManager.sharedInstance().mozillaBundle),
            self.buildUpdateSection()
        ]
        self.tableView.reloadData()
    }

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
        self.sections[indexPath.section].cells[indexPath.row].didSelect?(tableView, indexPath)
    }

    @IBAction func doneButtonTap(_ sender: UIBarButtonItem) {
        self.parent?.dismiss(animated: true)
    }
}
