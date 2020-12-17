import UIKit

class UIHelper {
    private var viewController: UIViewController!

    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }

    /// Present a generic alert in the given view controller. Alert has a single "Dismiss" button.
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - body: The body of the alert
    ///   - dismissed: Optional closure to call when the alert is dismissed
    public func presentAlert(title: String, body: String, dismissed: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: lang(key: "Dismiss"), style: .default) { (_) in
            dismissed?()
        }
        alertController.addAction(dismissButton)
        RunOnMain {
            self.viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Present a confirmation alert in the given view controller.
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - body: The body of the alert
    ///   - trueLabel: The label of the button that returns a "true" result
    ///   - falseLabel: The label of the button that returns a "false" result
    ///   - dismissed: Optional closure to call when the alert is dismissed
    public func presentConfirm(title: String, body: String, trueLabel: String, falseLabel: String, dismissed: ((Bool) -> Void)?) {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let trueButton = UIAlertAction(title: trueLabel, style: .default) { (_) in
            dismissed?(true)
        }
        let falseButton = UIAlertAction(title: falseLabel, style: .default) { (_) in
            dismissed?(false)
        }
        alertController.addAction(trueButton)
        alertController.addAction(falseButton)
        RunOnMain {
            self.viewController.present(alertController, animated: true, completion: nil)
        }
    }

    /// Present an error alert in the given view controller. Alert has a single "Dismiss" button.
    /// - Parameters:
    ///   - error: The error to display
    ///   - dismissed: Optional closure to call when the alert is dismissed
    public func presentError(error: Error, dismissed: (() -> Void)?) {
        self.presentAlert(title: "Error",
                          body: error.localizedDescription,
                          dismissed: dismissed)
    }

    /// Present an action sheet in the given view controller.
    /// - Parameters:
    ///   - target: The target of the action sheet
    ///   - title: Tht optional title of the action sheet
    ///   - subtitle: The optional subtitle of the action sheet
    ///   - items: The titles for each option
    ///   - dismissed: Optional closure to call when an option is selected. Cancel is -1.
    public func presentActionSheet(target: ActionTipTarget?,
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
        RunOnMain {
            self.viewController.present(controller, animated: true, completion: nil)
        }
    }
}
