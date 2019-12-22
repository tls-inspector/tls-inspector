import UIKit

class NoticeViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dismissButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        var forgroundColor = UIColor.black
        if #available(iOS 13, *) {
            forgroundColor = UIColor.label
        }
        let noticeText = NSMutableAttributedString(string: lang(key:"first_run_notice"),
                                                   attributes: [
                                                    NSAttributedString.Key.foregroundColor : forgroundColor,
                                                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18.0)
        ])
        let foundRange = noticeText.mutableString.range(of: lang(key: "Apple Support"))
        noticeText.addAttribute(NSAttributedString.Key.link, value: "https://support.apple.com/", range: foundRange)
        noticeText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 18.0), range: foundRange)

        self.textView.attributedText = noticeText
    }

    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
