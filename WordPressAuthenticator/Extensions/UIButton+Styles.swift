import UIKit

extension UIButton {
    /// Applies default styles to a plain text button.
    func applyTextButtonStyle() {
        setTitleColor(WordPressAuthenticator.shared.style.textButtonColor, for: .normal)
        setTitleColor(WordPressAuthenticator.shared.style.textButtonHighlightColor, for: .highlighted)
    }
}
