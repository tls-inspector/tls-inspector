import UIKit

@IBDesignable
public extension UILabel {

    @IBInspectable
    var textKey: String {
        get { return "" }
        set {
            self.text = lang.key(newValue)
        }
    }
}
