import UIKit
import IDNA

extension URL {
    static func fromString(str: String) -> URL? {
        // Only use IDNA if we have to
        if !str.canBeConverted(to: .ascii) {
            return URL.init(unicodeString: str)
        }

        return URL.init(string: str)
    }
}
