import UIKit
import MessageUI

class ContactTableViewController: UITableViewController, UITextViewDelegate {
    var contactType: SupportType.RequestType = .ReportABug
    var finishedBlock: ((SupportType) -> Void)!
    var comments: String = ""
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var warningView: UIView!

    static func show(_ viewController: UIViewController, finished: @escaping (SupportType) -> Void) {
        let storyboard = UIStoryboard.init(name: "More", bundle: Bundle.main)
        guard let contactViewController = storyboard.instantiateViewController(withIdentifier: "Contact") as? ContactTableViewController else { return }
        contactViewController.finishedBlock = finished
        viewController.present(UINavigationController(rootViewController: contactViewController), animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !MFMailComposeViewController.canSendMail() {
            UIHelper(self).presentAlert(title: lang(key: "Mail Account Required"),
                                        body: lang(key: "Contacting support requires that at least one email account be configured on this device.")) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    enum ValidationResult {
        case prohibited
        case warn
        case allowed
    }

    /**
     The TLS Inspector feedback mailbox recieves a surprising amount of spam, but also an unacceptible amount of vitrol and hate
     As a result, we've flagged some key-words that are common in these messages and will take two paths based on if they are found:
     "warn" words will generate a warning when you try to submit feedback with them. These are words such as "hack", "stole", etc, which are common among users who are confused as to what TLS Inspector is
     "prohibit" words are highly offensive, duragotory words that when found in the users comments will generate a "fake" feedback sent alert, without actually sending anything.
     */
    func validateFeedbackMessage(message: String) -> ValidationResult {

        guard let wordsPath = Bundle.main.path(forResource: "offensive_words", ofType: "plist") else {
            return .allowed
        }
        guard let encodedOffensiveWords = NSDictionary.init(contentsOfFile: wordsPath) as? [String: String] else {
            return .allowed
        }
        var offensiveWords: [String: String] = [:]
        encodedOffensiveWords.forEach { (key: String, value: String) in
            let word = String(data: Data.init(base64Encoded: key)!, encoding: .utf8)!
            offensiveWords[word] = value
        }

        let lcm = message.lowercased()
        for word in offensiveWords.keys where lcm.contains(word) {
            if offensiveWords[word] == "warn" {
                return .warn
            } else if offensiveWords[word] == "prohibit" {
                return .prohibited
            }
        }
        return .allowed
    }

    func finishFeedback() {
        let type = SupportType(type: self.contactType, comments: self.comments)
        self.dismiss(animated: true) {
            self.finishedBlock(type)
        }
    }

    @IBAction func doneButtonPushed(_ sender: Any) {
        let results = validateFeedbackMessage(message: self.comments)
        if results == .warn {
            UIHelper(self).presentConfirm(title: lang(key: "Important"), body: lang(key: "feedback_warn_message"), trueLabel: lang(key: "Send Anyways"), falseLabel: lang(key: "Discard")) { (confirm) in
                if confirm {
                    self.finishFeedback()
                }
            }
            return
        } else if results == .prohibited {
            // Fake a delay while we "send" the feedback
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            sleep(1)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            UIHelper(self).presentAlert(title: lang(key: "Feedback Sent"), body: lang(key: "fake_feedback_recieved_message")) {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }

        self.finishFeedback()
    }

    @IBAction func cancelButtonPushed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func textViewDidChange(_ textView: UITextView) {
        let words = textView.text?.split(separator: " ").joined(separator: "\n").split(separator: "\n")
        self.doneButton.isEnabled = (words?.count ?? 0) >= 5
        self.comments = textView.text
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.rowHeight
        } else {
            return 100.0
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }

        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
            let type = SupportType.RequestType.allValues()[indexPath.row]

            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = lang(key: type.rawValue)
            }

            if let iconLabel = cell.viewWithTag(2) as? UILabel {
                if self.contactType == type {
                    iconLabel.font = FAIcon.FACheckCircleSolid.font(size: 20.0)
                    iconLabel.text = FAIcon.FACheckCircleSolid.string()
                    iconLabel.textColor = UIColor.systemBlue
                } else {
                    iconLabel.font = FAIcon.FACircleRegular.font(size: 20.0)
                    iconLabel.text = FAIcon.FACircleRegular.string()
                    iconLabel.textColor = UIColor.gray
                }
            }
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Input", for: indexPath)
            if let input = cell.viewWithTag(1) as? UITextView {
                input.delegate = self
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let type = SupportType.RequestType.allValues()[indexPath.row]
            self.contactType = type
            tableView.reloadSections([0], with: .none)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return lang(key: "Select Feedback Type")
        } else {
            return lang(key: "Feedback")
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return lang(key: "Please describe the problem in at least 5 words.")
        }

        return nil
    }
}
