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

import SwiftUI
import MessageUI

enum FeedbackType {
    case bug
    case feature
    case somethingElse
}

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackType: FeedbackType = .bug
    @State private var feedbackMessage: String = ""
    @State private var feedbackIsValid = false
    @State private var showMailController = false
    @State private var showConfirmSend = false
    @State private var showFakeSend = false
    @State private var showProgressOverlay = false
    @State private var cantSendMail: Bool

    init() {
        cantSendMail = !MFMailComposeViewController.canSendMail()
    }

    var body: some View {
        Navigation {
            FeedbackInputView(feedbackType: $feedbackType, feedbackMessage: $feedbackMessage)
            .navigationTitle(Localize.providefeedback())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localize.cancel()) {
                        self.dismiss()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button(Localize.submit()) {
                        Task {
                            await self.submitFeedback()
                        }
                    }
                    .bold()
                    .disabled(!self.feedbackIsValid)
                }
            }
            .onChange(of: self.feedbackMessage) { _, _ in
                self.feedbackIsValid = self.feedbackMessage.count >= 20
            }
            .alert(Localize.pleasenote(), isPresented: $showConfirmSend) {
                Button(Localize.cancel()) {
                    //
                }
                Button(Localize.sendfeedback()) {
                    self.showMailController = true
                }
            } message: {
                Text(Localize.supportnote())
            }
            .alert(Localize.feedbacksent(), isPresented: $showFakeSend) {
                Button(Localize.dismiss()) {
                    self.dismiss()
                }
            } message: {
                Text(Localize.yourfeedbackhasbeensent())
            }
            .alert(Localize.mailaccountrequired(), isPresented: $cantSendMail) {
                Button(Localize.dismiss()) {
                    self.dismiss()
                }
            } message: {
                Text(Localize.contactsupportrequiresmailaccount())
            }
        }
        .fullScreenCover(isPresented: $showMailController, content: {
            FeedbackMailView(feedbackMessage: feedbackMessage, dismiss: dismiss)
        })
        .progressOverlay(presented: $showProgressOverlay)
    }

    func submitFeedback() async {
        switch FeedbackFilter.evalulate(self.feedbackMessage) {
        case .pass:
            self.showMailController = true
        case .reject:
            self.showProgressOverlay = true
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            self.showProgressOverlay = false
            self.showFakeSend = true
        case .warn:
            self.showConfirmSend = true
        }
    }
}

private struct FeedbackInputView: View {
    public let feedbackType: Binding<FeedbackType>
    public let feedbackMessage: Binding<String>
    private let isEnglish = UserOptions.current.appLanguage == .English

    var body: some View {
        List {
            Section(Localize.selectfeedbacktype()) {
                ListButton(showDisclosureIndicator: false) {
                    self.feedbackType.wrappedValue = .bug
                } label: {
                    Label(Localize.reportabug(), systemImage: self.feedbackType.wrappedValue == .bug ? "checkmark.circle.fill" : "circle")
                }
                ListButton(showDisclosureIndicator: false) {
                    self.feedbackType.wrappedValue = .feature
                } label: {
                    Label(Localize.requestafeature(), systemImage: self.feedbackType.wrappedValue == .feature ? "checkmark.circle.fill" : "circle")
                }
                ListButton(showDisclosureIndicator: false) {
                    self.feedbackType.wrappedValue = .somethingElse
                } label: {
                    Label(Localize.somethingelse(), systemImage: self.feedbackType.wrappedValue == .somethingElse ? "checkmark.circle.fill" : "circle")
                }
            }
            Section(Localize.providedetails()) {
                TextField(Localize.providefeedbackdetails(), text: self.feedbackMessage, axis: .vertical)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5, reservesSpace: true)
            }
            Section {
                if !isEnglish {
                    HStack(alignment: .top) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.accent)
                        Text(Localize.supportisonlyprovidedinenglish())
                    }
                }
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.accent)
                    Text(Localize.supportnote())
                }
            }
        }
    }
}

private struct FeedbackMailView: View {
    let feedbackMessage: String
    let dismiss: DismissAction
    private let attachments: [MailAttachment]

    init(feedbackMessage: String, dismiss: DismissAction) {
        self.feedbackMessage = feedbackMessage
        self.dismiss = dismiss

        if let logData = try? Data(contentsOf: LogWriter.shared.filePath) {
            self.attachments = [
                MailAttachment(fileName: "tls-inspector_log.txt", data: logData, mimeType: "text/plain")
            ]
        } else {
            self.attachments = []
        }
    }

    var body: some View {
        MFMailComposeViewControllerRepresentable(
            subject: "TLS Inspector Feedback",
            recipients: ["hello@tlsinspector.com"],
            messageBody: EnvironmentInfo.feedbackBodyHtml(withMessage: self.feedbackMessage),
            attachments: self.attachments,
            didFinish: {(_, _) in
                self.dismiss()
            })
    }
}
