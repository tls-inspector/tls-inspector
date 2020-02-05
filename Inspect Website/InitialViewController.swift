import UIKit
import MobileCoreServices
import CertificateKit

class InitialViewController: UIViewController, CKGetterDelegate {
    var values: [URL] = []
    let latch = AtomicInt(defaultValue: 0)
    let getter = CKGetter(options: UserOptions.getterOptions())
    var certificateChain: CKCertificateChain?
    var serverInfo: CKServerInfo?
    var observer: NSObjectProtocol?
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // swiftlint:disable cyclomatic_complexity
    override func viewDidLoad() {
        super.viewDidLoad()

        MigrateAssistant.AppLaunch()

        if #available(iOS 13, *) {
            self.activityIndicator.style = .large
        }

        if CertificateKit.isProxyConfigured() {
            UIHelper(self).presentAlert(title: lang(key: "Proxy Detected"),
                                        body: lang(key: "proxy_warning"),
                                        dismissed: nil)
            self.closeExtension()
            return
        }

        // We use a notification to know when the user dismissed the split view
        self.observer = NotificationCenter.default.addObserver(forName: VIEW_CLOSE_NOTIFICATION,
                                                               object: nil,
                                                               queue: nil) { (_) in
            self.closeExtension()
        }

        // When you load an item from the attachment provider, it may make a HTTP request to fetch metadata
        // about that resource - we use the latch to determine if any of these potential requests may be
        // in progress when we check for URLs.
        for object in self.extensionContext?.inputItems ?? [] {
            guard let item = object as? NSExtensionItem else {
                continue
            }

            for provider in item.attachments ?? [] {
                let contentText = item.attributedContentText?.string
                // Share page from within Safari
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    self.latch.increment()
                    provider.loadItem(forTypeIdentifier: (kUTTypeURL as String), options: nil) { (urlObj, _) in
                        self.latch.decrement()
                        if let url = urlObj as? URL {
                            self.values.append(url)
                            RunOnMain { self.checkValues() }
                        }
                    }
                // Share page from third-party browsers (Chrome, Brave 🦁)
                } else if let urlString = contentText {
                    if let url = URL(string: urlString) {
                        self.values.append(url)
                        RunOnMain { self.checkValues() }
                    }
                // Long-press on URL in Safari or share from other app
                } else if provider.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {
                    self.latch.increment()
                    provider.loadItem(forTypeIdentifier: (kUTTypePlainText as String), options: nil) { (text, _) in
                        self.latch.decrement()
                        if let url = URL(string: text as? String ?? "") {
                            self.values.append(url)
                            RunOnMain { self.checkValues() }
                        }
                    }
                }
            }
        }
        RunOnMain { self.checkValues() }
    }
    // swiftlint:enable cyclomatic_complexity

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.closeExtension()
    }

    func closeExtension() {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer, name: VIEW_CLOSE_NOTIFICATION, object: nil)
        }
        self.extensionContext?.completeRequest(returningItems: self.extensionContext?.inputItems,
                                               completionHandler: nil)
    }

    func checkValues() {
        if self.latch.get() > 0 {
            return
        }

        if self.values.count == 0 {
            UIHelper(self).presentAlert(
            title: lang(key: "No Supported URL Found"),
            body: lang(key: "If you believe this to be in error, contact support from within the TLS Inspector app.")) {
                self.closeExtension()
            }
        }

        var foundURL = false
        for url in values {
            if url.scheme != "https" {
                continue
            }

            foundURL = true
            inspectURL(url: url)
        }

        if !foundURL {
            UIHelper(self).presentAlert(
            title: lang(key: "No Supported URL Found"),
            body: lang(key: "Only HTTPS URLs can be inspected")) {
                self.closeExtension()
            }
        }
    }

    func inspectURL(url: URL) {
        self.getter.delegate = self
        self.getter.getInfoFor(url)
    }

    // MARK: CKGetterDelegate Methods
    func finishedGetter(_ getter: CKGetter, successful success: Bool) {
        print("Getter finished, success: \(success)")
        RunOnMain {
            if !success && self.certificateChain == nil {
                return
            }
            CKLogging.sharedInstance().writeWarn("CertificateChain getter suceeded but ServerInfo failed - ignoreing failure")

            CERTIFICATE_CHAIN = self.certificateChain
            SERVER_INFO = self.serverInfo
            self.performSegue(withIdentifier: "Inspect", sender: nil)
        }
    }

    func getter(_ getter: CKGetter, gotCertificateChain chain: CKCertificateChain) {
        self.certificateChain = chain
        print("Got certificate chain")
    }

    func getter(_ getter: CKGetter, gotServerInfo serverInfo: CKServerInfo) {
        self.serverInfo = serverInfo
        print("Got server info")
    }

    func getter(_ getter: CKGetter, errorGettingCertificateChain error: Error) {
        print("Error getting certificate chain: " + error.localizedDescription)
        UIHelper(self).presentError(error: error) {
            self.closeExtension()
        }
    }

    func getter(_ getter: CKGetter, errorGettingServerInfo error: Error) {
        print("Error server info: " + error.localizedDescription)
        SERVER_ERROR = error
    }
}
