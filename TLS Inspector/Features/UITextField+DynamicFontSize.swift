import UIKit

@IBDesignable
extension UITextField {
    @IBInspectable var fontName: String {
        get {
            return self.font?.fontName ?? ""
        }
        set {
            if newValue != "" {
                guard let customFont = UIFont(name: newValue, size: UIFont.labelFontSize) else {
                    fatalError("Failed to load custom font name")
                }
                self.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: customFont)
                self.adjustsFontForContentSizeCategory = true
            }
        }
    }
}
