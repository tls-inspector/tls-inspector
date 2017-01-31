import UIKit

@IBDesignable
public extension UITabBarItem {

    @IBInspectable
    var titleKey: String {
        get { return "" }
        set {
            self.title = lang.key(newValue)
        }
    }
}
