import SwiftUI
import UIKit
import MessageUI

struct MailAttachment: Sendable {
    let fileName: String
    let data: Data
    let mimeType: String
}

struct MFMailComposeViewControllerRepresentable: UIViewControllerRepresentable {
    let subject: String?
    let recipients: [String]?
    let messageBody: String?
    let attachments: [MailAttachment]?
    private let delegateHandler: MFMailComposeViewControllerDelegateHandler

    init(subject: String?, recipients: [String]?, messageBody: String?, attachments: [MailAttachment]?, didFinish: @escaping (MFMailComposeResult, Error?) -> Void) {
        self.subject = subject
        self.recipients = recipients
        self.messageBody = messageBody
        self.attachments = attachments
        self.delegateHandler = MFMailComposeViewControllerDelegateHandler(didFinish: { result, error in
            didFinish(result, error)
        })
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self.delegateHandler
        if let subject = self.subject {
            controller.setSubject(subject)
        }
        if let recipients = self.recipients {
            controller.setToRecipients(recipients)
        }
        if let messageBody = self.messageBody {
            controller.setMessageBody(messageBody, isHTML: true)
        }
        for attachment in attachments ?? [] {
            controller.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.fileName)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        //
    }
}

@MainActor
private final class MFMailComposeViewControllerDelegateHandler: NSObject, @preconcurrency MFMailComposeViewControllerDelegate {
    let didFinish: (MFMailComposeResult, Error?) -> Void

    init(didFinish: @escaping (MFMailComposeResult, Error?) -> Void) {
        self.didFinish = didFinish
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        controller.dismiss(animated: true) {
            self.didFinish(result, error)
        }
    }
}
