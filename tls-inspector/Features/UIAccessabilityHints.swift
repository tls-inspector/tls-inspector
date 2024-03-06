import UIKit

@IBDesignable
extension UIBarButtonItem {
    @IBInspectable var accessibilityUse: String {
        get {
            return self.accessibilityUse
        }
        set {
            self.accessibilityLabel = newValue
        }
    }
}

@IBDesignable
extension UITableView {
    @IBInspectable var accessibilityUse: String {
        get {
            return self.accessibilityUse
        }
        set {
            self.accessibilityLabel = newValue
        }
    }
}

@IBDesignable
extension UITableViewCell {
    @IBInspectable var accessibilityUse: String {
        get {
            return self.accessibilityUse
        }
        set {
            self.accessibilityLabel = newValue
        }
    }
}

@IBDesignable
extension UITextField {
    @IBInspectable var accessibilityUse: String {
        get {
            return self.accessibilityUse
        }
        set {
            self.accessibilityLabel = newValue
        }
    }
}
