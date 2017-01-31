import UIKit

@IBDesignable
public extension UINavigationItem {

    @IBInspectable
    var titleKey: String {
        get { return "" }
        set {
            self.title = lang.key(newValue)
        }
    }
}
