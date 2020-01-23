import UIKit

class MoreTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
