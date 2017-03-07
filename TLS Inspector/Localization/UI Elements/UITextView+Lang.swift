import UIKit

@IBDesignable
public extension UITextView {

    @IBInspectable
    var textKey: String {
        get { return "" }
        set {
            self.isSelectable = true
            self.text = lang.key(newValue)
            self.isSelectable = false
        }
    }
}
