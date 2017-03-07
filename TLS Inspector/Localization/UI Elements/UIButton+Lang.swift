import UIKit

@IBDesignable
public extension UIButton {

    @IBInspectable
    var defaultTitleKey: String {
        get { return "" }
        set {
            self.setTitle(lang.key(newValue), for: .normal)
        }
    }

    @IBInspectable
    var highLightedTitleKey: String {
        get { return "" }
        set {
            self.setTitle(lang.key(newValue), for: .highlighted)
        }
    }

    @IBInspectable
    var selectedTitleKey: String {
        get { return "" }
        set {
            self.setTitle(lang.key(newValue), for: .selected)
        }
    }

    @IBInspectable
    var disabledTitleKey: String {
        get { return "" }
        set {
            self.setTitle(lang.key(newValue), for: .disabled)
        }
    }
}
