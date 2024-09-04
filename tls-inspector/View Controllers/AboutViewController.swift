import UIKit
import CertificateKit
import WebKit

class AboutTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let projectGithubURL = "https://tlsinspector.com/github.html"
    let projectURL = "https://tlsinspector.com/"
    let projectContributeURL = "https://tlsinspector.com/contribute.html"
    let testflightURL = "https://tlsinspector.com/beta.html"
    let mastodonURL = "https://infosec.exchange/@tlsinspector"
    @IBOutlet weak var lockCircle: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var quotes: [String] = []
    var taps = 0
    var sections: [TableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let q = loadQuotes() {
            self.quotes = q
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapPicture(target:)))
        self.lockCircle.isUserInteractionEnabled = true
        self.lockCircle.addGestureRecognizer(tap)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissView))

        self.sections = [
            buildShareSection(),
            buildGetInvolvedSection()
        ]

        if #available(iOS 15, *) {
            self.sections.append(buildMoreFromSection())
        }
    }

    @objc func dismissView(_ sendor: Any?) {
        self.dismiss(animated: true)
    }

    func buildShareSection() -> TableViewSection {
        let section = TableViewSection()
        section.title = lang(key: "Share & Feedback")
        let opensslVersion = CertificateKit.opensslVersion()
        let libcurlVersion = CertificateKit.libcurlVersion()
        section.footer = "App: \(AppInfo.version()) (\(AppInfo.build())), OpenSSL: \(opensslVersion), curl: \(libcurlVersion)"

        let shareCell = TableViewCell(UITableViewCell())
        shareCell.cell.textLabel?.text = lang(key: "Share TLS Inspector")
        shareCell.didSelect = { _, _ in
            let blurb = lang(key: "Trust & Safety On-The-Go with TLS Inspector: {url}", args: [self.projectURL])
            let activityController = UIActivityViewController(activityItems: [blurb], applicationActivities: nil)
            ActionTipTarget(view: shareCell.cell).attach(to: activityController.popoverPresentationController)
            self.present(activityController, animated: true, completion: nil)
        }

        let rateCell = TableViewCell(UITableViewCell())
        rateCell.cell.textLabel?.text = lang(key: "Rate in App Store")
        rateCell.didSelect = { _, _ in
            AppLinks.current.showAppStoreIn(self, appId: AppLinks.tlsInspectorAppId, dismissed: nil)
        }

        var cells = [
            shareCell,
            rateCell
        ]

        if #available(iOS 15, *) {
            let feedbackCell = TableViewCell(UITableViewCell())
            feedbackCell.cell.textLabel?.text = lang(key: "Provide Feedback")
            feedbackCell.didSelect = { _, _ in
                ContactTableViewController.show(self) { (support) in
                    AppLinks.current.showEmailCompose(viewController: self, object: support, includeLogs: false, dismissed: nil)
                }
            }
            cells.append(feedbackCell)
        }

        section.cells = cells
        return section
    }

    func buildGetInvolvedSection() -> TableViewSection {
        let section = TableViewSection()
        section.title = lang(key: "Get Involved")
        section.footer = lang(key: "copyright_license_footer")

        let followCell = TableViewCell(UITableViewCell())
        followCell.cell.textLabel?.text = lang(key: "Follow @tlsinspector on Mastodon")
        followCell.cell.imageView?.image = UIImage(named: "Mastodon")
        followCell.didSelect = { _, _ in
            OpenURLInSafari(self.mastodonURL)
        }

        let contributeCell = TableViewCell(UITableViewCell())
        contributeCell.cell.textLabel?.text = lang(key: "Contribute to TLS Inspector")
        contributeCell.didSelect = { _, _ in
            OpenURLInSafari(self.projectContributeURL)
        }

        let attributeCell = TableViewCell(UITableViewCell())
        attributeCell.cell.textLabel?.text = lang(key: "Open Source Licenses & Attributions")
        attributeCell.didSelect = { _, _ in
            guard let attrPath = Bundle.main.url(forResource: "attr", withExtension: "html") else { return }
            guard let attrHtml = try? String(contentsOf: attrPath) else { return }

            let viewController = UIViewController()
            let webView = WKWebView()
            viewController.view = webView
            viewController.title = "Open Source Licenses & Attributions"
            webView.loadHTMLString(attrHtml, baseURL: nil)
            self.navigationController?.pushViewController(viewController, animated: true)
        }

        section.cells = [
            followCell,
            contributeCell,
            attributeCell,
        ]

        return section
    }

    func buildMoreFromSection() -> TableViewSection {
        let section = TableViewSection()

        section.title = lang(key: "More from the developer")

        let dnsInspectorCell = TableViewCell(UITableViewCell())
        dnsInspectorCell.cell.imageView?.image = UIImage(named: "DNS Inspector Icon")
        dnsInspectorCell.cell.textLabel?.text = "DNS Inspector"
        dnsInspectorCell.didSelect = { _, _ in
            AppLinks.current.showAppStoreIn(self, appId: AppLinks.dnsInspectorAppId, dismissed: nil)
        }

        section.cells.append(dnsInspectorCell)

        return section
    }

    func loadQuotes() -> [String]? {
        guard let quotesPath = Bundle.main.path(forResource: "QuoteList", ofType: "plist") else { return nil }
        guard let quotes = NSArray.init(contentsOfFile: quotesPath) as? [String] else { return nil }
        return quotes
    }

    @objc func didTapPicture(target: UIImageView) {
        if self.quotes.count == 0 {
            return
        }

        self.taps += 1
        if self.taps >= 3 {
            self.taps = 0

            UIHelper(self).presentAlert(title: self.quotes.randomElement() ?? "", body: "", dismissed: nil)
        }
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cells[indexPath.row].cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sections[section].footer
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let action = self.sections[indexPath.section].cells[indexPath.row].didSelect else { return }
        action(tableView, indexPath)
    }
}
