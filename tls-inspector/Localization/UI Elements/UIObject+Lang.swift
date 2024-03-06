import UIKit

@IBDesignable
extension UILabel {
    @IBInspectable var textKey: String {
        get {
            return self.textKey
        }
        set {
            self.text = lang(key: newValue)
        }
    }
}

@IBDesignable
extension UIBarButtonItem {
    @IBInspectable var titleKey: String {
        get {
            return self.titleKey
        }
        set {
            self.title = lang(key: newValue)
        }
    }
}

@IBDesignable
extension UIButton {
    @IBInspectable var defaultTitleKey: String {
        get {
            return self.defaultTitleKey
        }
        set {
            self.setTitle(lang(key: newValue), for: .normal)
        }
    }

    @IBInspectable var highLightedTitleKey: String {
        get {
            return self.highLightedTitleKey
        }
        set {
            self.setTitle(lang(key: newValue), for: .highlighted)
        }
    }

    @IBInspectable var selectedTitleKey: String {
        get {
            return self.selectedTitleKey
        }
        set {
            self.setTitle(lang(key: newValue), for: .selected)
        }
    }

    @IBInspectable var disabledTitleKey: String {
        get {
            return self.disabledTitleKey
        }
        set {
            self.setTitle(lang(key: newValue), for: .disabled)
        }
    }
}

@IBDesignable
extension UINavigationItem {
    @IBInspectable var titleKey: String {
        get {
            return self.titleKey
        }
        set {
            self.title = lang(key: newValue)
        }
    }
}

@IBDesignable
extension UISearchBar {
    @IBInspectable var placeholderKey: String {
        get {
            return self.placeholderKey
        }
        set {
            self.placeholder = lang(key: newValue)
        }
    }
}

@IBDesignable
extension UISegmentedControl {
    @IBInspectable var titleKey0: String {
        get {
            return self.titleKey0
        }
        set {
            self.setTitle(lang(key: newValue), forSegmentAt: 0)
        }
    }

    @IBInspectable var titleKey1: String {
        get {
            return self.titleKey1
        }
        set {
            self.setTitle(lang(key: newValue), forSegmentAt: 1)
        }
    }

    @IBInspectable var titleKey2: String {
        get {
            return self.titleKey2
        }
        set {
            self.setTitle(lang(key: newValue), forSegmentAt: 2)
        }
    }

    @IBInspectable var titleKey3: String {
        get {
            return self.titleKey3
        }
        set {
            self.setTitle(lang(key: newValue), forSegmentAt: 3)
        }
    }

    @IBInspectable var titleKey4: String {
        get {
            return self.titleKey4
        }
        set {
            self.setTitle(lang(key: newValue), forSegmentAt: 4)
        }
    }

    @IBInspectable var titleKey5: String {
        get {
            return self.titleKey5
        }
        set {
            self.setTitle(lang(key: newValue), forSegmentAt: 5)
        }
    }
}

@IBDesignable
extension UITabBarItem {
    @IBInspectable var titleKey: String {
        get {
            return self.titleKey
        }
        set {
            self.title = lang(key: newValue)
        }
    }
}

@IBDesignable
extension UITextView {
    @IBInspectable var textKey: String {
        get {
            return self.textKey
        }
        set {
            self.text = lang(key: newValue)
        }
    }
}

@IBDesignable
extension UIViewController {
    @IBInspectable var titleKey: String {
        get {
            return self.titleKey
        }
        set {
            self.title = lang(key: newValue)
        }
    }
}
