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
    let tipKeys: [String] = ["tip_1", "tip_2", "tip_3", "tip_4", "tip_5", "tip_6"]

    var certificateChain: CKCertificateChain?
    var serverInfo: CKServerInfo?
    var chainError: Error?
    var serverError: Error?

    var domainInput: UITextField?
    var advancedButton: UIButton?
    @IBOutlet weak var inspectButton: UIBarButtonItem!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipTextView: UILabel!

    override func viewDidLoad() {
        AppState.getterViewController = self

        if !UserOptions.firstRunCompleted {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Notice") {
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
            UserOptions.firstRunCompleted = true
        }

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

        domainInput?.placeholder = RandomDomainName.get()
        super.viewWillAppear(animated)
    }

    // MARK: Interface Actions
    @IBAction func moreButtonPressed(_ sender: Any) {
        self.present(UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "More"), animated: true, completion: nil)
    }

    @IBAction func inspectButtonPressed(_ sender: UIBarButtonItem) {
        let text = self.domainInput?.text ?? ""
        self.inspectDomain(text)
    }

    @IBAction func advancedButtonPressed(_ sender: OptionsButton) {
        guard let advancedInspect = self.storyboard?.instantiateViewController(withIdentifier: "AdvancedInspect") as? AdvancedInspectTableViewController else {
            return
        }

        advancedInspect.donePressed = { (parameters: CKInspectParameters) -> Void in
            self.doInspect(parameters: parameters)
        }

        let navigationController = UINavigationController(rootViewController: advancedInspect)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.sourceView = sender
        self.present(navigationController, animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.inputIsValid() && textField.text != nil {
            textField.resignFirstResponder()
            self.inspectDomain(textField.text!)
            return true
        } else {
            return false
        }
    }

    @objc func domainInputChanged(sender: UITextField) {
        self.inspectButton.isEnabled = self.inputIsValid()

        guard let advancedButton = self.advancedButton else {
            return
        }

        let length = sender.text?.count ?? 0
        if length > 0 {
            UIView.animate(withDuration: 0.1) {
                advancedButton.alpha = 0.0
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                advancedButton.alpha = 1.0
            }
        }
    }

    func inputIsValid() -> Bool {
        return (self.domainInput?.text ?? "").count > 0
    }

    func doInspect(parameters: CKInspectParameters) {
        // Reset
        self.certificateChain = nil
        self.serverInfo = nil
        self.chainError = nil
        self.serverError = nil
        CERTIFICATE_CHAIN = nil
        SERVER_INFO = nil
        SERVER_ERROR = nil

        if UserOptions.verboseLogging {
            CKLogging.sharedInstance().level = .debug
        } else {
            CKLogging.sharedInstance().level = .warning
        }

        self.domainInput?.isEnabled = false
        self.updatePendingCell(state: .loading)
        self.inspectButton.isEnabled = false
        self.getter = CKGetter()
        self.getter?.delegate = self
        LogDebug("Inspecting domain")
        self.getter?.getInfo(parameters)
    }

    func inspectDomain(_ query: String) {
        if CertificateKit.isProxyConfigured() {
            UIHelper(self).presentAlert(title: lang(key: "Proxy Detected"), body: lang(key: "proxy_warning"), dismissed: nil)
            return
        }

        self.doInspect(parameters: UserOptions.inspectParameters(hostAddress: query))
    }

    func reloadWithQuery(query: String) {
        self.presentedViewController?.dismiss(animated: true, completion: {
            RunOnMain {
                self.inspectDomain(query)
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
            CURRENT_CERTIFICATE = 0

            self.performSegue(withIdentifier: "Inspect", sender: nil)
            self.updatePendingCell(state: .none)
            if let domainInput = self.domainInput {
                domainInput.isEnabled = true
                domainInput.text = ""
                self.domainInputChanged(sender: domainInput)
            }
            let domainsBefore = RecentLookups.GetRecentLookups().count
            RecentLookups.Add(getter.parameters)
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

    func getter(_ getter: CKGetter, unexpectedError error: Error) {
        UIHelper(self).presentError(error: error) {
            self.serverInfo = nil
            self.certificateChain = nil
            self.chainError = nil
            self.serverError = nil
            self.updatePendingCell(state: .none)
            self.domainInput?.isEnabled = true
        }
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
            return cellForInputSection(indexPath)
        } else if indexPath.section == 1 {
            return cellForRecentSection(indexPath)
        }

        return UITableViewCell()
    }

    func cellForInputSection(_ indexPath: IndexPath) -> UITableViewCell {
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
            textField.placeholder = RandomDomainName.get()
            textField.addTarget(self, action: #selector(self.domainInputChanged(sender:)), for: .editingChanged)
        }

        if let advancedButton = cell.viewWithTag(2) as? UIButton {
            self.advancedButton = advancedButton
            advancedButton.addTarget(self, action: #selector(self.advancedButtonPressed(_:)), for: .touchUpInside)
        }

        return cell
    }

    func recentDetails(_ parameters: CKInspectParameters) -> String? {
        var details: [String] = []
        let defaultParameters = UserOptions.inspectParameters(hostAddress: parameters.hostAddress)

        if parameters.cryptoEngine != defaultParameters.cryptoEngine {
            details.append(lang(key: parameters.cryptoEngineString))
        }
        if let ipAddress = parameters.ipAddress {
            details.append(String(format: "IP: %@", ipAddress))
        }
        if parameters.port != 0 && parameters.port != 443 {
            details.append(String(format: "Port: %u", parameters.port))
        }
        if parameters.ipVersion != defaultParameters.ipVersion {
            details.append(lang(key: "IP version: {version}", args: [parameters.ipVersionString]))
        }

        if details.count == 0 {
            return nil
        }
        return details.joined(separator: ", ")
    }

    func cellForRecentSection(_ indexPath: IndexPath) -> UITableViewCell {
        let lookup = RecentLookups.GetRecentLookups()[indexPath.row]
        let details = recentDetails(lookup)

        let cell = details == nil ? tableView.dequeueReusableCell(withIdentifier: "Basic", for: indexPath) : tableView.dequeueReusableCell(withIdentifier: "Subtitle", for: indexPath)

        guard let titleLabel = cell.viewWithTag(1) as? UILabel else {
            return cell
        }
        titleLabel.text = lookup.hostAddress

        if let subtitleLabel = cell.viewWithTag(2) as? UILabel {
            subtitleLabel.text = details ?? ""
        }

        return cell
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
            let countBefore = RecentLookups.GetRecentLookups().count
            RecentLookups.RemoveLookup(index: indexPath.row)
            let countAfter = RecentLookups.GetRecentLookups().count

            if countBefore == countAfter {
                // Don't update the table to avoid a potential crash
                return
            }

            if countAfter == 0 {
                tableView.deleteSections([1], with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }

        let inspect = UITableViewRowAction(style: .normal, title: lang(key: "Inspect")) { (_, _) in
            let lookup = RecentLookups.GetRecentLookups()[indexPath.row]
            self.doInspect(parameters: lookup)
        }
        inspect.backgroundColor = UIColor.systemBlue

        return [delete, inspect]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }

        let lookup = RecentLookups.GetRecentLookups()[indexPath.row]
        self.doInspect(parameters: lookup)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Error" {
            let destination = segue.destination as? GetterErrorTableViewController
            destination?.chainError = self.chainError
            destination?.serverError = self.serverError
        }
    }
}
