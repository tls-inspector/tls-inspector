import UIKit

class UIHelper: NSObject {
    /// Present a generic alert in the given view controller. Alert has a single "Dismiss" button.
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

    /// Present an error alert in the given view controller. Alert has a single "Dismiss" button.
    /// - Parameters:
    ///   - viewController: The view controller to present the alert in
    ///   - error: The error to display
    ///   - dismissed: Optional closure to call when the alert is dismissed
    static func presentError(viewController: UIViewController, error: Error, dismissed: (() -> Void)?) {
        UIHelper.presentAlert(viewController: viewController,
                              title: "Error",
                              body: error.localizedDescription,
                              dismissed: dismissed)
    }

    static func presentActionSheet(viewController: UIViewController,
                                   target: ActionTipTarget?,
                                   title: String?,
                                   subtitle: String?,
                                   items: [String],
                                   dismissed: ((Int) -> Void)?) {
        let controller = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: lang(key: "Cancel"), style: .cancel) { (_) in
            dismissed?(-1)
        }
        controller.addAction(cancelButton)
        for (idx, title) in items.enumerated() {
            let action = UIAlertAction(title: title, style: .default) { (_) in
                dismissed?(idx)
            }
            controller.addAction(action)
        }
        target?.attach(to: controller.popoverPresentationController)
        viewController.present(controller, animated: true, completion: nil)
    }
}
