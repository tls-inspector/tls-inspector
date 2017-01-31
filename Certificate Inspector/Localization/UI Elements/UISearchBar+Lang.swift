import UIKit

@IBDesignable
public extension UISearchBar {

    @IBInspectable
    var placeholderKey: String {
        get { return "" }
        set {
            self.placeholder = lang.key(newValue)
        }
    }
}
