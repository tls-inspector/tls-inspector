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
