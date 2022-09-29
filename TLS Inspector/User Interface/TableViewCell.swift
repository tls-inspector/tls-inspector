import UIKit

class TableViewCell {
    public var cell: UITableViewCell

    public var didSelect: ((UITableView, IndexPath) -> Void)?
    public var willSelect: ((UITableView, IndexPath) -> Void)?
    public var shouldShowMenu: ((UITableView, IndexPath) -> Bool)?
    public var canPerformAction: ((UITableView, Selector, IndexPath, Any?) -> Bool)?
    public var performAction: ((UITableView, Selector, IndexPath, Any?) -> Void)?

    init(_ cell: UITableViewCell) {
        self.cell = cell
    }
}
