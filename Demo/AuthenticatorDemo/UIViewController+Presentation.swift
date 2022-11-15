import UIKit

extension UIViewController {

    func presentAlert(
        title: String,
        message: String,
        animated: Bool = true,
        onDismiss: @escaping () -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.present(
                UIAlertController.withSingleDismissButton(
                    title: title,
                    message: message,
                    onDismiss: onDismiss
                ),
                animated: animated
            )
        }
    }
}
