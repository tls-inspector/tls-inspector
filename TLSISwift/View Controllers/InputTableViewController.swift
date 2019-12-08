import UIKit
import CertificateKit

class InputTableViewController: UITableViewController, CKGetterDelegate {
    var domainInput: UITextField?
    @IBOutlet weak var inspectButton: UIBarButtonItem!
    var isLoading = false
    var getter: CKGetter?
    var certificateChain: CKCertificateChain?
    var serverInfo: CKServerInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Loading", for: indexPath)
            if let activity = cell.viewWithTag(1) as? UIActivityIndicatorView {
                activity.startAnimating()
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "Input", for: indexPath)

        if let textField = cell.viewWithTag(1) as? UITextField {
            self.domainInput = textField
            textField.addTarget(self, action: #selector(self.domainInputChanged(sender:)), for: .editingChanged)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Domain Name or IP Address"
    }
    
    @objc func domainInputChanged(sender: UITextField) {
        if let text = sender.text {
            self.inspectButton.isEnabled = text.count > 0
        } else {
            self.inspectButton.isEnabled = false
        }
    }

    @IBAction func inspectButtonPressed(_ sender: UIBarButtonItem) {
        self.domainInput?.isEnabled = false
        self.isLoading = true
        let text = self.domainInput?.text ?? ""
        self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        self.inspectButton.isEnabled = false
        self.inspectDomain(text: text)
    }
    
    func inspectDomain(text: String) {
        var domainText = text
        if domainText.hasPrefix("http://") {
            showInputError()
        }

        if !domainText.hasPrefix("https://") {
            domainText = "https://" + domainText
        }
        
        let options = CKGetterOptions()

        options.checkOCSP = true
        options.checkCRL = false
        options.queryServerInfo = true
        options.useOpenSSL = true
        options.ciphers = "HIGH:!aNULL:!MD5:!RC4"
        CertificateKit.setLoggingLevel(.debug)

        self.getter = CKGetter(options: options)
        self.getter?.delegate = self
        if let url = URL(string: domainText) {
            print("Inspecting domain")
            self.getter?.getInfoFor(url)
        } else {
            showInputError()
        }
    }
    
    func showInputError() {
        UIHelper.presentAlert(viewController: self, title: "Unable to Inspect Domain", body: "The URL or IP Address inputted is not valid") {
            self.isLoading = false
            self.tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            self.domainInput?.isEnabled = true
            self.domainInput?.text = ""
        }
    }
    
    // MARK: Getter Delegates
    func finishedGetter(_ getter: CKGetter) {
        print("Getter finished")
        guard let chain = self.certificateChain else {
            showInputError()
            return
        }
        guard let info = self.serverInfo else {
            showInputError()
            return
        }
        
        CERTIFICATE_CHAIN = chain
        SERVER_INFO = info
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "Inspect", sender: nil)
        }
    }
    
    func getter(_ getter: CKGetter, gotCertificateChain chain: CKCertificateChain) {
        print("Got certificate chain")
        self.certificateChain = chain
    }
    
    func getter(_ getter: CKGetter, gotServerInfo serverInfo: CKServerInfo) {
        print("Got server info")
        self.serverInfo = serverInfo
    }
    
    func getter(_ getter: CKGetter, errorGettingCertificateChain error: Error) {
        UIHelper.presentError(viewController: self, error: error, dismissed: nil)
        print("Error getting certificate chain")
    }
    
    func getter(_ getter: CKGetter, errorGettingServerInfo error: Error) {
        UIHelper.presentError(viewController: self, error: error, dismissed: nil)
        print("Error getting server info")
    }
}
