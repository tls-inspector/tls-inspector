import UIKit

@IBDesignable
public extension UIViewController {
    
    @IBInspectable
    var titleKey: String {
        get { return "" }
        set {
            self.title = lang.key(newValue)
        }
    }
}
