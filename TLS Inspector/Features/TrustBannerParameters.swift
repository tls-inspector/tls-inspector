import UIKit
import CertificateKit

class TrustBannerParameters {
    let color: UIColor
    let cornerRadius: CGFloat
    let icon: FAIcon
    let solid: Bool
    let text: String
    let textColor: UIColor

    init(trust: CKCertificateChainTrustStatus) {
        var color = UIColor.materialPink()
        var icon = FAIcon.FAQuestionCircleSolid
        var solid = true
        var text = lang(key: "Unknown")
        var textColor = UIColor.white

        switch trust {
        case .trusted:
            color = UIColor.materialGreen()
            text = lang(key: "Trusted")
            icon = FAIcon.FACheckCircleSolid
        case .locallyTrusted:
            if UserOptions.treatUnrecognizedAsTrusted {
                color = UIColor.materialLightGreen()
                text = lang(key: "Locally Trusted")
                icon = FAIcon.FACheckCircleRegular
            } else {
                solid = false
                color = UIColor.materialAmber()
                text = lang(key: "Unrecognized")
                icon = FAIcon.FACheckCircleRegular
                textColor = SPLIT_VIEW_CONTROLLER?.traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
            }
        case .untrusted, .invalidDate, .wrongHost:
            color = UIColor.materialAmber()
            text = lang(key: "Untrusted")
            icon = FAIcon.FAExclamationCircleSolid
        case .sha1Leaf, .sha1Intermediate:
            color = UIColor.materialRed()
            text = lang(key: "Insecure")
            icon = FAIcon.FATimesCircleSolid
        case .selfSigned, .revokedLeaf, .revokedIntermediate:
            color = UIColor.materialRed()
            text = lang(key: "Untrusted")
            icon = FAIcon.FATimesCircleSolid
        case .leafMissingRequiredKeyUsage:
            color = UIColor.materialAmber()
            text = lang(key: "Untrusted")
            icon = FAIcon.FAExclamationCircleSolid
        case .weakRSAKey:
            color = UIColor.materialRed()
            text = lang(key: "Insecure")
            icon = FAIcon.FATimesCircleSolid
        case .issueDateTooLong:
            color = UIColor.materialAmber()
            text = lang(key: "Untrusted")
            icon = FAIcon.FAExclamationCircleSolid
        case .badAuthority:
            color = UIColor.materialRed(level: 900) ?? UIColor.materialRed()
            text = lang(key: "Dangerous")
            icon = FAIcon.FAExclamationTriangleSolid
        @unknown default:
            color = UIColor.materialPink()
            text = lang(key: "Unknown")
            icon = FAIcon.FAQuestionCircleSolid
        }

        self.color = color
        self.cornerRadius = 10.0
        self.icon = icon
        self.solid = solid
        self.text = text
        self.textColor = textColor
    }
}
