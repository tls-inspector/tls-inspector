import UIKit

class OptionsButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.updateImage()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.updateImage()
    }

    func updateImage() {
        guard let image = UIImage(named: "Options") else { return }
        self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        self.imageView?.tintColor = UIColor.systemBlue
    }
}
