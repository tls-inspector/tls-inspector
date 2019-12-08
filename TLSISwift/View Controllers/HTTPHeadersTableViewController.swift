import UIKit
import CertificateKit

class HTTPHeadersTableViewController: UITableViewController {

    var headers: [String:String] = [:]
    var headerKeysSorted: [String] = []

    override func viewDidLoad() {
        if let serverInfo = SERVER_INFO {
            self.headerKeysSorted = serverInfo.headers.keys.sorted()
            self.headers = serverInfo.headers
        }

        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.headerKeysSorted.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = self.headerKeysSorted[indexPath.row]
        let value = self.headers[key] ?? ""

        return TitleValueTableViewCell.Cell(title: key, value: value, useFixedWidthFont: true)
    }
}
