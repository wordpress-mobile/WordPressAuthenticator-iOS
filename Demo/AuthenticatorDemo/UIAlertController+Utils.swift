import UIKit

extension UIAlertController {

    static func withSingleDismissButton(
        title: String,
        message: String,
        onDismiss: @escaping () -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default) { _ in onDismiss() })
        return alert
    }
}
