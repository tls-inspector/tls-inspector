import UIKit

extension UILabel {
    @IBInspectable var bold: Bool {
        get {
            return self.font.fontName.lowercased().contains("bold")
        }
        set {
            guard let descriptor = self.font.fontDescriptor.withSymbolicTraits(.traitBold) else {
                return
            }
            self.font = UIFont(descriptor: descriptor, size: self.font.pointSize)
        }
    }
}
