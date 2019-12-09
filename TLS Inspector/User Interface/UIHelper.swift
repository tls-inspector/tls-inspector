import UIKit

class UIHelper: NSObject {
    /// Present a generic alert in the given view controller. Alert has a single, "Dismiss" button.
    /// - Parameters:
    ///   - viewController: The view controller to present the alert in
    ///   - title: The title of the alert
    ///   - body: The body of the alert
    ///   - dismissed: Optional closure to call when the alert is dismissed
    static func presentAlert(viewController: UIViewController, title: String, body: String, dismissed: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .default) { (_) in
            dismissed?()
        }
        alertController.addAction(dismissButton)
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }

    static func presentError(viewController: UIViewController, error: Error, dismissed: (() -> Void)?) {
        UIHelper.presentAlert(viewController: viewController,
                              title: "Error",
                              body: error.localizedDescription,
                              dismissed: dismissed)
    }
}
