import UIKit
import CertificateKit

class InputTableViewController: UITableViewController, UITextFieldDelegate, ReloadableInspectTarget {
    enum PendingCellStates {
        case none
        case loading
        case error
    }

    var pendingCellState: PendingCellStates = .none
    let tipKeys: [String] = ["tip_1", "tip_2", "tip_3", "tip_4", "tip_5", "tip_6"]
    let requestQueue = DispatchQueue(label: "com.ecnepsnai.Certificate-Inspector.RequestQueue")

    var certificateChain: CKCertificateChain?
    var httpServerInfo: CKHTTPServerInfo?
    var chainError: Error?
    var serverError: Error?

    var domainInput: UITextField?
    var advancedButton: UIButton?
    @IBOutlet weak var inspectButton: UIBarButtonItem!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipTextView: UILabel!
    @IBOutlet weak var moreButton: UIBarButtonItem!

    override func viewDidLoad() {
        reloadInspectionTarget = self

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
        NotificationCenter.default.addObserver(forName: CHANGE_CRYPTO_NOTIFICATION, object: nil, queue: nil) { (_) in
            self.tableView.reloadData()
        }
        // swiftlint:enable discarded_notification_center_observer

        if #available(iOS 14, *) {
            let actions: [UIAction] = [
                UIAction(title: lang(key: "About TLS Inspector"), image: UIImage(named: "info.circle.fill"), identifier: UIAction.Identifier("about")) { _ in
                    self.showAboutView()
                },
                UIAction(title: lang(key: "Options"), image: UIImage(named: "gearshape.circle.fill"), identifier: UIAction.Identifier("options")) { _ in
                    self.showOptionsView()
                }
            ]

            let menu = UIMenu(title: "", children: actions)
            moreButton.menu = menu
        } else {
            moreButton.target = self
            moreButton.action = #selector(moreButtonTap)
        }

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

    @objc func moreButtonTap(_ sender: Any?) { // iOS 12-13 only
        UIHelper(self).presentActionSheet(target: ActionTipTarget(barButtonItem: self.moreButton), title: nil, subtitle: nil, items: [
            lang(key: "About TLS Inspector"),
            lang(key: "Options")
        ]) { index in
            switch index {
            case 0:
                self.showAboutView()
            case 1:
                self.showOptionsView()
            default:
                break
            }
        }
    }

    func showAboutView() {
        let aboutView = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "AboutTableViewController")
        self.showChildViewController(aboutView)
    }

    func showOptionsView() {
        let optionsView = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "OptionsTableViewController")
        self.showChildViewController(optionsView)
    }

    func showChildViewController(_ controller: UIViewController) {
        let navigationView = UINavigationController(rootViewController: controller)
        self.present(navigationView, animated: true)
    }

    @IBAction func inspectButtonPressed(_ sender: UIBarButtonItem) {
        let text = self.domainInput?.text ?? ""
        self.inspectWithQuery(text)
    }

    @IBAction func advancedButtonPressed(_ sender: OptionsButton) {
        guard let advancedInspect = self.storyboard?.instantiateViewController(withIdentifier: "AdvancedInspect") as? AdvancedInspectTableViewController else { return }

        advancedInspect.donePressed = { (parameters: CKInspectParameters) in
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
            self.inspectWithQuery(textField.text!)
            return true
        } else {
            return false
        }
    }

    @objc func domainInputChanged(sender: UITextField) {
        self.inspectButton.isEnabled = self.inputIsValid()

        guard let advancedButton = self.advancedButton else { return }

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
        if CertificateKit.isProxyConfigured() {
            if let view = self.storyboard?.instantiateViewController(withIdentifier: "ProxyNotice") {
                view.modalPresentationStyle = .fullScreen
                self.present(view, animated: true)
            }

            return
        }

        // Reset
        self.certificateChain = nil
        self.httpServerInfo = nil
        self.chainError = nil
        self.serverError = nil
        CERTIFICATE_CHAIN = nil
        HTTP_SERVER_INFO = nil
        SERVER_ERROR = nil

        if UserOptions.verboseLogging {
            CKLogging.sharedInstance().level = .debug
        } else {
            CKLogging.sharedInstance().level = .warning
        }

        self.domainInput?.isEnabled = false
        self.updatePendingCell(state: .loading)
        self.inspectButton.isEnabled = false

        let request = CKInspectRequest(parameters: parameters)
        request.execute(on: requestQueue) { oResponse, oError in
            RunOnMain {
                if let error = oError {
                    self.chainError = error
                    self.updatePendingCell(state: .error)
                    self.domainInput?.isEnabled = true
                }
                if let response = oResponse {
                    UserOptions.inspectionsWithVerboseLogging += 1
                    CERTIFICATE_CHAIN = response.certificateChain
                    HTTP_SERVER_INFO = response.httpServer
                    CURRENT_CERTIFICATE = 0

                    self.performSegue(withIdentifier: "Inspect", sender: nil)
                    self.updatePendingCell(state: .none)
                    if let domainInput = self.domainInput {
                        domainInput.isEnabled = true
                        domainInput.text = ""
                        self.domainInputChanged(sender: domainInput)
                    }
                    let domainsBefore = RecentLookups.GetRecentLookups().count
                    RecentLookups.Add(parameters)
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
        }
    }

    func inspectWithQuery(_ query: String) {
        self.doInspect(parameters: UserOptions.inspectParameters(hostAddress: query))
    }

    func reloadWithQuery(query: String) {
        self.presentedViewController?.dismiss(animated: true, completion: {
            RunOnMain {
                self.inspectWithQuery(query)
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
