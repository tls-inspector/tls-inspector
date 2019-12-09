import UIKit

@IBDesignable
class GradientView: UIView {

    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    // swiftlint:disable force_cast
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    // swiftlint:enable force_cast

    func updatePoints() {
        gradientLayer.startPoint = .init(x: 1, y: 0)
        gradientLayer.endPoint = .init(x: 0, y: 1)
    }
    func updateLocations() {
        gradientLayer.locations = [0.0 as NSNumber, 1.0 as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
