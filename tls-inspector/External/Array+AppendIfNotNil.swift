import UIKit

extension Array {
    mutating func maybeAppend(_ object: Element?) {
        if let o = object {
            self.append(o)
        }
    }
}
