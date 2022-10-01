import UIKit
import CertificateKit

class AboutTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let projectGithubURL = "https://tlsinspector.com/github.html"
    let projectURL = "https://tlsinspector.com/"
    let projectContributeURL = "https://tlsinspector.com/contribute.html"
    let testflightURL = "https://tlsinspector.com/beta.html"
    let twitterURL = "https://twitter.com/tlsinspector"
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

        self.sections = [
            buildShareSection(),
            buildGetInvolvedSection()
        ]
    }

    func buildShareSection() -> TableViewSection {
        let section = TableViewSection()
        section.title = lang(key: "Share & Feedback")
        let opensslVersion = CertificateKit.opensslVersion()
        let libcurlVersion = CertificateKit.libcurlVersion()
        section.footer = "App: \(AppInfo.version()) (\(AppInfo.build())), OpenSSL: \(opensslVersion), tiny-curl: \(libcurlVersion)"

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
            cell.textLabel?.text = lang(key: "Contribute to TLS Inspector")
        } else if indexPath.section == 1 && indexPath.row == 1 {
            cell.textLabel?.text = lang(key: "Test New Features")
        } else if indexPath.section == 1 && indexPath.row == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "Twitter", for: indexPath)
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
            let opensslVersion = CertificateKit.opensslVersion()
            let libcurlVersion = CertificateKit.libcurlVersion()
            return "App: \(AppInfo.version()) (\(AppInfo.build())), OpenSSL: \(opensslVersion), tiny-curl: \(libcurlVersion)"
        } else if section == 1 {
            return lang(key: "copyright_license_footer")
        }

        return nil
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
            OpenURLInSafari(projectContributeURL)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            OpenURLInSafari(testflightURL)
        } else if indexPath.section == 1 && indexPath.row == 2 {
            OpenURLInSafari(twitterURL)
        }
    }
}
