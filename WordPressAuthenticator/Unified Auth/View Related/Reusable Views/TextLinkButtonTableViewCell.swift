import UIKit


/// TextLinkButtonTableViewCell: a plain button made to look like a text link.
///
class TextLinkButtonTableViewCell: UITableViewCell {
    
    /// Private properties
    ///
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var borderWidth: NSLayoutConstraint!
    @IBAction private func textLinkButtonTapped(_ sender: UIButton) {
        actionHandler?()
    }
    
    /// Public properties
    ///
    public static let reuseIdentifier = "TextLinkButtonTableViewCell"
    
    public var actionHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        button.titleLabel?.adjustsFontForContentSizeCategory = true
        styleBorder()
    }
    
    public func configureButton(text: String?, accessibilityTrait: UIAccessibilityTraits = .button, showBorder: Bool = false) {
        button.setTitle(text, for: .normal)
        
        let buttonTitleColor = WordPressAuthenticator.shared.unifiedStyle?.textButtonColor ?? WordPressAuthenticator.shared.style.textButtonColor
        let buttonHighlightColor = WordPressAuthenticator.shared.unifiedStyle?.textButtonHighlightColor ?? WordPressAuthenticator.shared.style.textButtonHighlightColor
        button.setTitleColor(buttonTitleColor, for: .normal)
        button.setTitleColor(buttonHighlightColor, for: .highlighted)
        button.accessibilityTraits = accessibilityTrait
        
        borderView.isHidden = !showBorder
    }
    
    /// Toggle button enabled / disabled
    ///
    public func enableButton(_ isEnabled: Bool) {
        button.isEnabled = isEnabled
    }

}


// MARK: - Private methods
private extension TextLinkButtonTableViewCell {

    /// Style the bottom cell border, called borderView.
    ///
    func styleBorder() {
        let borderColor = WordPressAuthenticator.shared.unifiedStyle?.borderColor ?? WordPressAuthenticator.shared.style.primaryNormalBorderColor
        borderView.backgroundColor = borderColor
        borderWidth.constant = WPStyleGuide.hairlineBorderWidth
    }
}
