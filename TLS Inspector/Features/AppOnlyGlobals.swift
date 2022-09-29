import UIKit

func OpenURLInSafari(_ urlString: String) {
    guard let url = URL(string: urlString) else { return }

    UIApplication.shared.open(url)
}
