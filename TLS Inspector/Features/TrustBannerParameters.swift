import UIKit
import CertificateKit

class TrustBannerParameters {
    let solid: Bool
    let color: UIColor
    let text: String
    let icon: FAIcon
    let cornerRadius: CGFloat

    init(trust: CKCertificateChainTrustStatus) {
        switch trust {
        case .trusted:
            self.solid = true
            self.color = UIColor.materialGreen()
            self.text = lang(key: "Trusted")
            self.icon = FAIcon.FACheckCircleSolid
        case .locallyTrusted:
            if UserOptions.treatUnrecognizedAsTrusted {
                self.solid = true
                self.color = UIColor.materialLightGreen()
                self.text = lang(key: "Locally Trusted")
                self.icon = FAIcon.FACheckCircleRegular
            } else {
                self.solid = false
                self.color = UIColor.materialAmber()
                self.text = lang(key: "Unrecognized")
                self.icon = FAIcon.FACheckCircleRegular
            }
        case .untrusted, .invalidDate, .wrongHost:
            self.solid = true
            self.color = UIColor.materialAmber()
            self.text = lang(key: "Untrusted")
            self.icon = FAIcon.FAExclamationCircleSolid
        case .sha1Leaf, .sha1Intermediate:
            self.solid = true
            self.color = UIColor.materialRed()
            self.text = lang(key: "Insecure")
            self.icon = FAIcon.FATimesCircleSolid
        case .selfSigned, .revokedLeaf, .revokedIntermediate:
            self.solid = true
            self.color = UIColor.materialRed()
            self.text = lang(key: "Untrusted")
            self.icon = FAIcon.FATimesCircleSolid
        case .leafMissingRequiredKeyUsage:
            self.solid = true
            self.color = UIColor.materialAmber()
            self.text = lang(key: "Untrusted")
            self.icon = FAIcon.FAExclamationCircleSolid
        case .weakRSAKey:
            self.solid = true
            self.color = UIColor.materialRed()
            self.text = lang(key: "Insecure")
            self.icon = FAIcon.FATimesCircleSolid
        case .issueDateTooLong:
            self.solid = true
            self.color = UIColor.materialAmber()
            self.text = lang(key: "Untrusted")
            self.icon = FAIcon.FAExclamationCircleSolid
        case .badAuthority:
            self.solid = true
            self.color = UIColor.materialRed(level: 900) ?? UIColor.materialRed()
            self.text = lang(key: "Dangerous")
            self.icon = FAIcon.FAExclamationTriangleSolid
        @unknown default:
            self.solid = true
            self.color = UIColor.materialPink()
            self.text = lang(key: "Unknown")
            self.icon = FAIcon.FAQuestionCircleSolid
        }
        self.cornerRadius = 10.0
    }
}
