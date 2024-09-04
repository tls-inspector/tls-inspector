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
        let attachments = self.extensionContext?.inputItems ?? []
        print("[\(#fileID):\(#line)] Extension started with \(attachments.count) attachments")
        for object in self.extensionContext?.inputItems ?? [] {
            guard let item = object as? NSExtensionItem else {
                continue
            }

            guard let attachments = item.attachments else {
                continue
            }

            for attachment in attachments {
                guard let attachmentType = attachment.registeredTypeIdentifiers.first else {
                    continue
                }

                if attachmentType != "public.url" {
                    print("[\(#fileID):\(#line)] Skipping attachment with type \(attachmentType)")
                    continue
                }

                print("[\(#fileID):\(#line)] Attachment type: \(attachmentType)")

                self.latch.increment()
                self.findURLFromAttachmentItem(attachment) { result in
                    self.latch.decrement()
                    switch result {
                    case .success(let url):
                        self.values.append(url)
                        RunOnMain { self.checkValues() }
                    case .failure(let failure):
                        UIHelper(self).presentError(error: failure) {
                            self.closeExtension()
                        }
                    }
                }
            }
        }
        RunOnMain { self.checkValues() }
    }

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
                guard let response = oResponse else {
                    self.closeExtension()
                    return
                }

                CERTIFICATE_CHAIN = response.certificateChain
                HTTP_SERVER_INFO = response.httpServer
                self.performSegue(withIdentifier: "Inspect", sender: nil)
            }
        }
    }

    func findURLFromAttachmentItem(_ attachment: NSItemProvider, _ complete: @escaping (Result<URL, Error>) -> Void) {
        attachment.loadItem(forTypeIdentifier: "public.url") { (oValue, oError) in
            if let error = oError {
                print("[\(#fileID):\(#line)] Error loading attachment item: \(error)")
                complete(.failure(error))
                return
            }
            guard let value = oValue else {
                print("[\(#fileID):\(#line)] Error loading attachment item: nil value")
                complete(.failure(NSError(domain: "com.ecnepsnai.Certificate-Inspector.Inspect-Website", code: 1, userInfo: [NSLocalizedDescriptionKey: "Attachment has no value"])))
                return
            }
            // Check of the attachment item is a URL
            if let url = value as? URL {
                print("[\(#fileID):\(#line)] Got URL: \(url)")
                complete(.success(url))
                return
            }
            // Check of the attachment item is a string containing a URL
            if let url = URL(string: value as? String ?? "") {
                print("[\(#fileID):\(#line)] Got URL: \(url)")
                complete(.success(url))
                return
            }
            // Check of the attachment item is raw bytes of a string containing a URL (yes, really, Safari on macOS will use this path)
            if let data = value as? Data, let urlString = String(data: data, encoding: .utf8), let url = URL(string: urlString) {
                print("[\(#fileID):\(#line)] Got URL: \(url)")
                complete(.success(url))
                return
            }
            print("[\(#fileID):\(#line)] Unable to parse attachment item: \(value)")
            complete(.failure(NSError(domain: "com.ecnepsnai.Certificate-Inspector.Inspect-Website", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse attachment value"])))
        }
    }
}
