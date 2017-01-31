import UIKit

@IBDesignable
public extension UIBarButtonItem {

    @IBInspectable
    var titleKey: String {
        get { return "" }
        set {
            self.title = lang.key(newValue)
        }
    }
}
