import UIKit
import CertificateKit

class InputTableViewController: UITableViewController, CKGetterDelegate, UITextFieldDelegate, ChainGetterViewController {
    enum PendingCellStates {
        case none
        case loading
        case error
    }

    var getter: CKGetter?
    var pendingCellState: PendingCellStates = .none
    var placeholderDomains: [String] = []
    let tipKeys: [String] = ["tlstip1", "tlstip2", "tlstip3", "tlstip5", "tlstip6", "tlstip7"]

    var certificateChain: CKCertificateChain?
    var serverInfo: CKServerInfo?
    var chainError: Error?
    var serverError: Error?

    var domainInput: UITextField?
    @IBOutlet weak var inspectButton: UIBarButtonItem!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipTextView: UILabel!

    override func viewDidLoad() {
        AppState.getterViewController = self

        if let domains = loadPlaceholderDomains() {
            self.placeholderDomains = domains
        }

        if !UserOptions.firstRunCompleted {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Notice") {
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
            UserOptions.firstRunCompleted = true
        }

        MigrateAssistant.AppLaunch()

        // swiftlint:disable discarded_notification_center_observer
        NotificationCenter.default.addObserver(forName: RELOAD_RECENT_NOTIFICATION, object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: SHOW_TIPS_NOTIFICATION, object: nil, queue: nil) { (_) in
            self.tipView.isHidden = !UserOptions.showTips
        }
        // swiftlint:enable discarded_notification_center_observer

        self.tipView.isHidden = !UserOptions.showTips
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let tip = tipKeys.randomElement() {
            self.tipTextView.text = lang(key: tip)
        }

        if let placeholder = placeholderDomains.randomElement() {
            domainInput?.placeholder = placeholder
        }

        super.viewWillAppear(animated)
    }

    // MARK: Interface Actions
    @IBAction func moreButtonPressed(_ sender: Any) {
        self.present(UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "More"), animated: true, completion: nil)
    }

    @IBAction func inspectButtonPressed(_ sender: UIBarButtonItem) {
        let text = self.domainInput?.text ?? ""
        self.inspectDomain(text: text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.inputIsValid() {
            textField.resignFirstResponder()
            self.inspectDomain(text: textField.text!)
            return true
        } else {
            return false
        }
    }

    func loadPlaceholderDomains() -> [String]? {
        guard let domainListPath = Bundle.main.path(forResource: "DomainList", ofType: "plist") else {
            return nil
        }
        guard let domains = NSArray.init(contentsOfFile: domainListPath) as? [String] else {
            return nil
        }
        return domains
    }

    @objc func domainInputChanged(sender: UITextField) {
        self.inspectButton.isEnabled = self.inputIsValid()
    }

    func inputIsValid() -> Bool {
        return (self.domainInput?.text ?? "").count > 0
    }

    func inspectDomain(text: String) {
        // Reset
        self.certificateChain = nil
        self.serverInfo = nil
        self.chainError = nil
        self.serverError = nil
        CERTIFICATE_CHAIN = nil
        SERVER_INFO = nil
        SERVER_ERROR = nil

        if CertificateKit.isProxyConfigured() {
            UIHelper(self).presentAlert(title: lang(key: "Proxy Detected"), body: lang(key: "proxy_warning"), dismissed: nil)
            return
        }

        // Show a non-generic error for hosts containing unicode as we don't
        // support them (GH Issue #43)
        if !text.canBeConverted(to: .ascii) {
            UIHelper(self).presentAlert(title: lang(key: "IDN Not Supported"), body: lang(key: "idn_warning"), dismissed: nil)
            return
        }

        self.domainInput?.isEnabled = false
        self.updatePendingCell(state: .loading)
        self.inspectButton.isEnabled = false

        var domainText = text
        if domainText.hasPrefix("http://") {
            showInputError()
        }

        if !domainText.hasPrefix("https://") {
            domainText = "https://" + domainText
        }

        if UserOptions.verboseLogging {
            CKLogging.sharedInstance().level = .debug
        } else {
            CKLogging.sharedInstance().level = .warning
        }

        self.getter = CKGetter(options: UserOptions.getterOptions())
        self.getter?.delegate = self
        if let url = URL(string: domainText) {
            LogDebug("Inspecting domain")
            self.getter?.getInfoFor(url)
        } else {
            showInputError()
        }
    }

    func showInputError() {
        self.updatePendingCell(state: .none)
        self.domainInput?.text = ""
        UIHelper(self).presentAlert(title: "Unable to Inspect Domain",
                                    body: "The URL or IP Address inputted is not valid") {
            self.domainInput?.isEnabled = true
        }
    }

    func reloadWithQuery(query: String) {
        self.presentedViewController?.dismiss(animated: true, completion: {
            RunOnMain {
                self.inspectDomain(text: query)
            }
        })
    }

    func updatePendingCell(state: PendingCellStates) {
        if self.pendingCellState == state {
            return
        }
        let stateBefore = self.pendingCellState
        self.pendingCellState = state

        // This is kinda verbose, but because Apple decided it is THE BEST IDEA
        // for the ENTIRE APP TO CRASH just because you tried to reload a cell
        // that isn't there, we do things this way to try and be safe.
        //
        // THANKS TIM 🍎
        if state == .none {
            self.tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        } else if state == .loading && stateBefore == .none {
            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        } else if state == .loading && stateBefore == .error {
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        } else if state == .error && stateBefore == .loading {
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        } else if state == .error && stateBefore == .none {
            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        } else {
            LogError("Unknown pending cell state: new=\(state) before=\(stateBefore)")
        }
    }

    // MARK: Getter Delegate Methods
    func finishedGetter(_ getter: CKGetter, successful success: Bool) {
        LogInfo("Getter finished, success: \(success)")
        RunOnMain {
            if !success && self.certificateChain == nil {
                return
            }
            if self.serverError != nil {
                LogWarn("Chain suceeded but Server failed - Ignoring error")
            }

            UserOptions.inspectionsWithVerboseLogging += 1
            CERTIFICATE_CHAIN = self.certificateChain
            SERVER_INFO = self.serverInfo

            self.performSegue(withIdentifier: "Inspect", sender: nil)
            self.updatePendingCell(state: .none)
            self.domainInput?.isEnabled = true
            self.domainInput?.text = ""
            let domainsBefore = RecentLookups.GetRecentLookups().count
            RecentLookups.AddLookup(getter.url)
            let recentLookups = RecentLookups.GetRecentLookups()
            if UserOptions.rememberRecentLookups && recentLookups.count > 0 {
                if recentLookups.count == 1 && domainsBefore == 0 {
                    self.tableView.insertSections([1], with: .automatic)
                } else {
                    self.tableView.reloadSections([1], with: .automatic)
                }
            }
        }
    }

    func getter(_ getter: CKGetter, gotCertificateChain chain: CKCertificateChain) {
        LogDebug("Got certificate chain")
        RunOnMain {
            self.certificateChain = chain
        }
    }

    func getter(_ getter: CKGetter, gotServerInfo serverInfo: CKServerInfo) {
        LogDebug("Got server info")
        RunOnMain {
            self.serverInfo = serverInfo
        }
    }

    func getter(_ getter: CKGetter, errorGettingCertificateChain error: Error) {
        LogError("Error getting certificate chain: \(error)")
        RunOnMain {
            self.chainError = error
            self.updatePendingCell(state: .error)
            self.domainInput?.isEnabled = true
        }
    }

    func getter(_ getter: CKGetter, errorGettingServerInfo error: Error) {
        LogError("Error getting server info: \(error)")
        self.serverError = error
        SERVER_ERROR = error
    }

    // MARK: Table View Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        if UserOptions.rememberRecentLookups && RecentLookups.GetRecentLookups().count > 0 {
            return 2
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.pendingCellState != .none {
                return 2
            }
            return 1
        } else if section == 1 {
            return RecentLookups.GetRecentLookups().count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                var cell: UITableViewCell!
                if self.pendingCellState == .loading {
                    cell = tableView.dequeueReusableCell(withIdentifier: "Loading", for: indexPath)
                    if let activity = cell.viewWithTag(1) as? UIActivityIndicatorView {
                        activity.startAnimating()

                        if #available(iOS 13, *) {
                            activity.style = .medium
                        }
                    }
                } else if self.pendingCellState == .error {
                    cell = tableView.dequeueReusableCell(withIdentifier: "Error", for: indexPath)
                }
                return cell
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "Input", for: indexPath)

            if let textField = cell.viewWithTag(1) as? UITextField {
                self.domainInput = textField
                textField.delegate = self
                textField.placeholder = placeholderDomains.randomElement()
                textField.addTarget(self, action: #selector(self.domainInputChanged(sender:)), for: .editingChanged)
            }

            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath)
            cell.textLabel?.text = RecentLookups.GetRecentLookups()[indexPath.row]
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return lang(key: "Domain Name or IP Address")
        } else if section == 1 {
            return lang(key: "Recent Lookups")
        }
        return ""
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }

    override func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            return nil
        }

        let delete = UITableViewRowAction(style: .destructive, title: lang(key: "Delete")) { (_, _) in
            RecentLookups.RemoveLookup(index: indexPath.row)
            if RecentLookups.GetRecentLookups().count == 0 {
                tableView.deleteSections([1], with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }

        let inspect = UITableViewRowAction(style: .normal, title: lang(key: "Inspect")) { (_, _) in
            let query = RecentLookups.GetRecentLookups()[indexPath.row]
            self.inspectDomain(text: query)
        }
        inspect.backgroundColor = UIColor.systemBlue

        return [delete, inspect]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }

        let query = RecentLookups.GetRecentLookups()[indexPath.row]
        self.inspectDomain(text: query)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Error" {
            let destination = segue.destination as? GetterErrorTableViewController
            destination?.chainError = self.chainError
            destination?.serverError = self.serverError
        }
    }
}
