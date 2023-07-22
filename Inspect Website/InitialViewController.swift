import UIKit
import MobileCoreServices
import CertificateKit

/// The initial view controller is responsible for bootstrapping the rest of the application and acting as the getter delegate.
/// This extension can be used in a number of places, and each can report the host URL in a different way.
class InitialViewController: UIViewController {
    var values: [URL] = []
    let latch = AtomicInt(defaultValue: 0)
    let requestQueue = DispatchQueue(label: "com.ecnepsnai.Inspect-Website.RequestQueue")
    var certificateChain: CKCertificateChain?
    var httpServerInfo: CKHTTPServerInfo?
    var observer: NSObjectProtocol?
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

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
                // Share page from within Safari 🧭
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
                // Long-press on URL in Safari or share from other app 👆
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

            guard let host = url.host else {
                continue
            }

            let port = UInt16(url.port ?? 443)

            foundURL = true
            doInspect(hostAddress: host, port: port)
        }

        if !foundURL {
            UIHelper(self).presentAlert(
            title: lang(key: "No Supported URL Found"),
            body: lang(key: "Only HTTPS URLs can be inspected")) {
                self.closeExtension()
            }
        }
    }

    func doInspect(hostAddress: String, port: UInt16) {
        let parameters = UserOptions.inspectParameters(hostAddress: hostAddress)
        parameters.port = port

        let request = CKInspectRequest(parameters: parameters)
        request.execute(on: requestQueue) { oResponse, oError in
            RunOnMain {
                if let error = oError {
                    UIHelper(self).presentError(error: error) {
                        self.closeExtension()
                    }
                    return
                }
                if let response = oResponse {
                    CERTIFICATE_CHAIN = response.certificateChain
                    HTTP_SERVER_INFO = response.httpServer
                    self.performSegue(withIdentifier: "Inspect", sender: nil)
                }
            }
        }
    }
}
