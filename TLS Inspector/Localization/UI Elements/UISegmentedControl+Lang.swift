import UIKit

@IBDesignable
public extension UISegmentedControl {

    @IBInspectable
    var titleKeyForIndex0: String {
        get { return "" }
        set {
            self.setTitle(lang.key(newValue), forSegmentAt: 0)
        }
    }

    @IBInspectable
    var titleKeyForIndex1: String {
        get { return "" }
        set {
            self.setTitle(lang.key(newValue), forSegmentAt: 1)
        }
    }

    @IBInspectable
    var titleKeyForIndex2: String {
        get { return "" }
        set {
            self.setTitle(lang.key(newValue), forSegmentAt: 2)
        }
    }

    @IBInspectable
    var titleKeyForIndex3: String {
        get { return "" }
        set {
            self.setTitle(lang.key(newValue), forSegmentAt: 3)
        }
    }

    @IBInspectable
    var titleKeyForIndex4: String {
        get { return "" }
        set {
            self.setTitle(lang.key(newValue), forSegmentAt: 4)
        }
    }
}
