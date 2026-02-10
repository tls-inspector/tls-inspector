// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import UIKit
import SwiftUI
import TLSKit
import TLSUI
import Localization
import DNSKit

/// The initial view controller is responsible for accepting the data sent by the system to the extension, try to determine the host that needs to be inspected, handle the inspection, and present the
/// results.
class InitialViewController: UIViewController {
    var observer: NSObjectProtocol?
    let latch: AtomicInt = AtomicInt(initialValue: 0)
    var values: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        TLSKit.log = LogWriter.shared
        DNSKit.log = DNSKitLoggerBridge.shared

        /// We use a notification to know when the user dismissed the split view
        NotificationCenter.default.addObserver(forName: closedInspectionViewNotification, object: nil, queue: nil) { _ in
            self.closeExtension()
        }

        if isProxyEnabled() {
            DispatchQueue.main.async {
                self.showProxyWarningView()
            }
            return
        }

        /// Actually getting the host from whatever input was passed to the extension is surprisingly complex.
        /// You'd think you could just access the relevant data type that maps to the activation rule, but instead there's a bunch of asynchronous logic
        /// because when you try to load an attachment it might make an addtional HTTP request to fetch metadata.
        /// We use a latch to determine if any of these potential requests may be in progress when we check for URL attachments.
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

                _ = self.latch.IncrementAndGet()
                self.findURLFromAttachmentItem(attachment) { result in
                    _ = self.latch.DecrementAndGet()
                    switch result {
                    case .success(let url):
                        self.values.append(url)
                        DispatchQueue.main.async {
                            self.checkValues()
                        }
                    case .failure(let failure):
                        DispatchQueue.main.async {
                            self.showErrorAndCloseExtension(Localize.error(), "\(failure)")
                        }
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.checkValues()
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

    func checkValues() {
        if self.latch.Get() > 0 {
            return
        }

        if self.values.count == 0 {
            self.showErrorAndCloseExtension(Localize.nosupportedurlfound(), Localize.ifyoubelievethistobeinerrorcontactsupportfromwithinthetlsinspectorapp())
            return
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
            Task {
                await executeInspectionRequest(host: host, port: port)
            }
        }

        if !foundURL {
            self.showErrorAndCloseExtension(Localize.nosupportedurlfound(), Localize.onlyhttpsurlscanbeinspected())
            return
        }
    }

    func showErrorAndCloseExtension(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            self.closeExtension()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    func executeInspectionRequest(host: String, port: UInt16) async {
        let request = InspectionRequest(
            address: host,
            port: port,
            checkCRL: UserOptions.current.checkCrl,
            checkOCSP: UserOptions.current.queryOcsp,
            ipVersion: UserOptions.current.ipVersion.toTLSKit(),
            checkHTTP: UserOptions.current.getHttpHeaders,
            timeoutSeconds: UInt8(UserOptions.current.inspectTimeout),
            alpn: ["http/1.1"],
        )
        let cryptoengine = UserOptions.current.cryptoEngine.toTLSKit()

        do {
            let session = InspectionSession(engineType: cryptoengine)
            let result = try await session.execute(request)
            DispatchQueue.main.async {
                let responseView = UIHostingController(rootView: InspectionResponseView(response: result))
                responseView.modalPresentationStyle = .fullScreen
                self.present(responseView, animated: false, completion: nil)
            }
        } catch {
            DispatchQueue.main.async {
                self.showErrorAndCloseExtension(Localize.error(), "\(error)")
            }
        }
    }

    func showProxyWarningView() {
        let warningView = UIHostingController(rootView: ProxyNoticeView())
        warningView.modalPresentationStyle = .fullScreen
        self.present(warningView, animated: false, completion: nil)
    }

    @IBAction func cancelButtonPress(_ sender: UIButton) {
        self.closeExtension()
    }

    func closeExtension() {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer, name: closedInspectionViewNotification, object: nil)
        }
        self.extensionContext?.completeRequest(returningItems: self.extensionContext?.inputItems,
                                               completionHandler: nil)
    }
}
