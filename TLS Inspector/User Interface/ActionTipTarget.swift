import UIKit

class ActionTipTarget {
    private var view: UIView?
    private var barButtonItem: UIBarButtonItem?

    init(view: UIView) {
        self.view = view
    }

    init(barButtonItem: UIBarButtonItem) {
        self.barButtonItem = barButtonItem
    }

    public func attach(to: UIPopoverPresentationController?) {
        if let view = self.view {
            to?.sourceView = view
        } else if let barButtonItem = self.barButtonItem {
            to?.barButtonItem = barButtonItem
        }
    }
}
