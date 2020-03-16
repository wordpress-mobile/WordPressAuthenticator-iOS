import WordPressShared
import WordPressUI
import Gridicons
import AuthenticationServices

final class SubheadlineButton: UIButton {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            titleLabel?.font = WPStyleGuide.mediumWeightFont(forStyle: .subheadline)
            setTitleColor(WordPressAuthenticator.shared.style.textButtonColor, for: .normal)
            setTitleColor(WordPressAuthenticator.shared.style.textButtonHighlightColor, for: .highlighted)
        }
    }
}

extension WPStyleGuide {

    private struct Constants {
        // This matches the button height in NUXButtonView.storyboard
        static let buttonMinHeight: CGFloat = 50.0

        static let textButtonMinHeight: CGFloat = 40.0
        static let googleIconOffset: CGFloat = -1.0
        static let domainsIconPaddingToRemove: CGFloat = 2.0
        static let domainsIconSize = CGSize(width: 18, height: 18)
        static let verticalLabelSpacing: CGFloat = 10.0
    }

    /// Common view style for signin view controllers.
    ///
    /// - Parameters:
    ///     - view: The view to style.
    ///
    class func configureColorsForSigninView(_ view: UIView) {
        view.backgroundColor = wordPressBlue()
    }

    /// Adds a 1password button to a WPWalkthroughTextField, if available
    ///
    class func configureOnePasswordButtonForTextfield(_ textField: WPWalkthroughTextField, target: NSObject, selector: Selector) {
        guard OnePasswordFacade.isOnePasswordEnabled else {
            return
        }

        let onePasswordButton = UIButton(type: .custom)
        onePasswordButton.setImage(.onePasswordImage, for: .normal)
        onePasswordButton.sizeToFit()

        onePasswordButton.accessibilityLabel =
            NSLocalizedString("Fill with password manager", comment: "The password manager button in login pages. The button opens a dialog showing which password manager to use (e.g. 1Password, LastPass). ")

        textField.rightView = onePasswordButton
        textField.rightViewMode = .always

        onePasswordButton.addTarget(target, action: selector, for: .touchUpInside)
    }

    /// Adds a 1password button to a stack view, if available
    ///
    class func configureOnePasswordButtonForStackView(_ stack: UIStackView, target: NSObject, selector: Selector) {
        guard OnePasswordFacade.isOnePasswordEnabled else {
            return
        }

        let onePasswordButton = UIButton(type: .custom)
        onePasswordButton.setImage(.onePasswordImage, for: .normal)
        onePasswordButton.sizeToFit()
        onePasswordButton.setContentHuggingPriority(.required, for: .horizontal)
        onePasswordButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        stack.addArrangedSubview(onePasswordButton)

        onePasswordButton.addTarget(target, action: selector, for: .touchUpInside)
    }

    /// Configures a plain text button with default styles.
    ///
    class func configureTextButton(_ button: UIButton) {
        button.setTitleColor(WordPressAuthenticator.shared.style.textButtonColor, for: .normal)
        button.setTitleColor(WordPressAuthenticator.shared.style.textButtonHighlightColor, for: .highlighted)
    }

    ///
    ///
    class func colorForErrorView(_ opaque: Bool) -> UIColor {
        let alpha: CGFloat = opaque ? 1.0 : 0.95
        return UIColor(fromRGBAColorWithRed: 17.0, green: 17.0, blue: 17.0, alpha: alpha)
    }

    ///
    ///
    class func edgeInsetForLoginTextFields() -> UIEdgeInsets {
        return UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 20)
    }

    class func textInsetsForLoginTextFieldWithLeftView() -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }

    /// Return the system font in medium weight for the given style
    ///
    /// - note: iOS won't return UIFontWeightMedium for dynamic system font :(
    /// So instead get the dynamic font size, then ask for the non-dynamic font at that size
    ///
    class func mediumWeightFont(forStyle style: UIFont.TextStyle, maximumPointSize: CGFloat = WPStyleGuide.maxFontSize) -> UIFont {
        let fontToGetSize = WPStyleGuide.fontForTextStyle(style)
        let maxAllowedFontSize = CGFloat.minimum(fontToGetSize.pointSize, maximumPointSize)
        return UIFont.systemFont(ofSize: maxAllowedFontSize, weight: .medium)
    }

    // MARK: - Login Button Methods

    /// Creates a button for Google Sign-in
    ///
    /// - Returns: A properly styled UIButton
    ///
    class func googleLoginButton() -> UIButton {
        let baseString =  NSLocalizedString("{G} Log in with Google.", comment: "Label for button to log in using Google. The {G} will be replaced with the Google logo.")

        let attrStrNormal = googleButtonString(baseString, linkColor: WordPressAuthenticator.shared.style.textButtonColor)
        let attrStrHighlight = googleButtonString(baseString, linkColor: WordPressAuthenticator.shared.style.textButtonHighlightColor)

        let font = WPStyleGuide.mediumWeightFont(forStyle: .subheadline)

        return textButton(normal: attrStrNormal, highlighted: attrStrHighlight, font: font)
    }

    /// Creates a button for Apple Sign-in
    ///
    /// - Returns: A properly styled UIControl
    ///
    
    class func appleLoginButton() -> UIControl {
        if #available(iOS 13.0, *) {
            let traits = UITraitCollection.current
            let buttonStyle: ASAuthorizationAppleIDButton.Style = (traits.userInterfaceStyle == .dark) ? .white : .black

            let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: buttonStyle)
            appleButton.translatesAutoresizingMaskIntoConstraints = false
            appleButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonMinHeight).isActive = true
            return appleButton
        }
        
        return UIControl()
    }
    
    /// Creates a button for Self-hosted Login
    ///
    /// - Returns: A properly styled UIButton
    ///
    class func selfHostedLoginButton(alignment: UIControl.NaturalContentHorizontalAlignment = .leading) -> UIButton {
        
        let style = WordPressAuthenticator.shared.style
        
        let button: UIButton

        if WordPressAuthenticator.shared.configuration.showLoginOptions {
            let baseString =  NSLocalizedString("Or log in by _entering your site address_.", comment: "Label for button to log in using site address. Underscores _..._ denote underline.")
            
            let attrStrNormal = baseString.underlined(color: style.subheadlineColor, underlineColor: style.textButtonColor)
            let attrStrHighlight = baseString.underlined(color: style.subheadlineColor, underlineColor: style.textButtonHighlightColor)
            let font = WPStyleGuide.mediumWeightFont(forStyle: .subheadline)
            
            button = textButton(normal: attrStrNormal, highlighted: attrStrHighlight, font: font, alignment: alignment)
        } else {
            let baseString = NSLocalizedString("Enter the address of the WordPress site you'd like to connect.", comment: "Label for button to log in using your site address.")
            
            let attrStrNormal = selfHostedButtonString(baseString, linkColor:  style.textButtonColor)
            let attrStrHighlight = selfHostedButtonString(baseString, linkColor: style.textButtonHighlightColor)
            let font = WPStyleGuide.mediumWeightFont(forStyle: .subheadline)
            
            button = textButton(normal: attrStrNormal, highlighted: attrStrHighlight, font: font)
        }
        
        button.accessibilityIdentifier = "Self Hosted Login Button"
        
        return button
    }

    /// Creates a button for wpcom signup on the email screen
    ///
    /// - Returns: A UIButton styled for wpcom signup
    /// - Note: This button is only used during Jetpack setup, not the usual flows
    ///
    class func wpcomSignupButton() -> UIButton {
        let style = WordPressAuthenticator.shared.style
        let baseString = NSLocalizedString("Don't have an account? _Sign up_", comment: "Label for button to log in using your site address. The underscores _..._ denote underline")
        let attrStrNormal = baseString.underlined(color: style.subheadlineColor, underlineColor: style.textButtonColor)
        let attrStrHighlight = baseString.underlined(color: style.subheadlineColor, underlineColor: style.textButtonHighlightColor)
        let font = WPStyleGuide.mediumWeightFont(forStyle: .subheadline)

        return textButton(normal: attrStrNormal, highlighted: attrStrHighlight, font: font)
    }

    /// Creates a button to open our T&C
    ///
    /// - Returns: A properly styled UIButton
    ///
    class func termsButton() -> UIButton {
        let style = WordPressAuthenticator.shared.style

        let baseString =  NSLocalizedString("By signing up, you agree to our _Terms of Service_.", comment: "Legal disclaimer for signup buttons, the underscores _..._ denote underline")

        let attrStrNormal = baseString.underlined(color: style.subheadlineColor, underlineColor: style.textButtonColor)
        let attrStrHighlight = baseString.underlined(color: style.subheadlineColor, underlineColor: style.textButtonHighlightColor)
        let font = WPStyleGuide.mediumWeightFont(forStyle: .footnote)

        return textButton(normal: attrStrNormal, highlighted: attrStrHighlight, font: font, alignment: .center)
    }

    private class func textButton(normal normalString: NSAttributedString, highlighted highlightString: NSAttributedString, font: UIFont, alignment: UIControl.NaturalContentHorizontalAlignment = .leading) -> UIButton {
        let button = SubheadlineButton()
        button.clipsToBounds = true

        button.naturalContentHorizontalAlignment = alignment
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = font
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(WordPressAuthenticator.shared.style.subheadlineColor, for: .normal) 

        // These constraints work around some issues with multiline buttons and
        // vertical layout.  Without them the button's height may not account
        // for the titleLabel's height.
        button.titleLabel?.topAnchor.constraint(equalTo: button.topAnchor, constant: Constants.verticalLabelSpacing).isActive = true
        button.titleLabel?.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -Constants.verticalLabelSpacing).isActive = true
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textButtonMinHeight).isActive = true


        button.setAttributedTitle(normalString, for: .normal)
        button.setAttributedTitle(highlightString, for: .highlighted)
        return button
    }

    private class func googleButtonString(_ baseString: String, linkColor: UIColor) -> NSAttributedString {
        let labelParts = baseString.components(separatedBy: "{G}")
        let font = WPStyleGuide.mediumWeightFont(forStyle: .subheadline)

        let firstPart = labelParts[0]
        // 👇 don't want to crash when a translation lacks "{G}"
        let lastPart = labelParts.indices.contains(1) ? labelParts[1] : ""

        let labelString = NSMutableAttributedString(string: firstPart, attributes: [.foregroundColor: WPStyleGuide.greyDarken30()])

        if lastPart != "" {
            let googleIcon = UIImage.googleIcon
            let googleAttachment = NSTextAttachment()
            googleAttachment.image = googleIcon
            googleAttachment.bounds = CGRect(x: 0.0, y: font.descender + Constants.googleIconOffset, width: googleIcon.size.width, height: googleIcon.size.height)
            let iconString = NSAttributedString(attachment: googleAttachment)
            labelString.append(iconString)
        }

        labelString.append(NSAttributedString(string: lastPart, attributes: [.foregroundColor: linkColor]))

        return labelString
    }

    private class func selfHostedButtonString(_ buttonText: String, linkColor: UIColor) -> NSAttributedString {
        let font = WPStyleGuide.mediumWeightFont(forStyle: .subheadline)

        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .left

        let labelString = NSMutableAttributedString(string: "")

        if let originalDomainsIcon = Gridicon.iconOfType(.domains).imageWithTintColor(WordPressAuthenticator.shared.style.placeholderColor) {
            var domainsIcon = originalDomainsIcon.cropping(to: CGRect(x: Constants.domainsIconPaddingToRemove,
                                                                      y: Constants.domainsIconPaddingToRemove,
                                                                      width: originalDomainsIcon.size.width - Constants.domainsIconPaddingToRemove * 2,
                                                                      height: originalDomainsIcon.size.height - Constants.domainsIconPaddingToRemove * 2))
            domainsIcon = domainsIcon.resizedImage(Constants.domainsIconSize, interpolationQuality: .high)
            let domainsAttachment = NSTextAttachment()
            domainsAttachment.image = domainsIcon
            domainsAttachment.bounds = CGRect(x: 0, y: font.descender, width: domainsIcon.size.width, height: domainsIcon.size.height)
            let iconString = NSAttributedString(attachment: domainsAttachment)
            labelString.append(iconString)
        }
        labelString.append(NSAttributedString(string: " " + buttonText, attributes: [.foregroundColor: linkColor]))

        return labelString
    }
}
