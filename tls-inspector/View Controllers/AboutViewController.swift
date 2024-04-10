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

        return section
    }

    func buildGetInvolvedSection() -> TableViewSection {
        let section = TableViewSection()
        section.title = lang(key: "Get Involved")
        section.footer = lang(key: "copyright_license_footer")

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
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if #unavailable(iOS 12) {
            return 0
        }

        if section == 0 {
            return 3
        } else if section == 1 {
            return 3
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
            return tableView.dequeueReusableCell(withIdentifier: "Mastodon", for: indexPath)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            cell.textLabel?.text = lang(key: "Contribute to TLS Inspector")
        } else if indexPath.section == 1 && indexPath.row == 2 {
            cell.textLabel?.text = lang(key: "Open Source Licenses & Attributions")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sections[section].footer
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        if indexPath.section == 0 && indexPath.row == 0 {
            let blub = lang(key: "Trust & Safety On-The-Go with TLS Inspector: {url}", args: [projectURL])
            let activityController = UIActivityViewController(activityItems: [blub], applicationActivities: nil)
            ActionTipTarget(view: cell).attach(to: activityController.popoverPresentationController)
            self.present(activityController, animated: true, completion: nil)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            AppLinks.current.showAppStore(self, dismissed: nil)
        } else if indexPath.section == 0 && indexPath.row == 2 {
            ContactTableViewController.show(self) { (support) in
                AppLinks.current.showEmailCompose(viewController: self, object: support, includeLogs: false, dismissed: nil)
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            OpenURLInSafari(mastodonURL)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            OpenURLInSafari(projectContributeURL)
        } else if indexPath.section == 1 && indexPath.row == 2 {
            guard let attrPath = Bundle.main.url(forResource: "attr", withExtension: "html") else { return }
            guard let attrHtml = try? String(contentsOf: attrPath) else { return }

            let viewController = UIViewController()
            let webView = WKWebView()
            viewController.view = webView
            viewController.title = "Open Source Licenses & Attributions"
            webView.loadHTMLString(attrHtml, baseURL: nil)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
