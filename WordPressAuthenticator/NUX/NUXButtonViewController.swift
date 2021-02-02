import UIKit
import WordPressKit

@objc public protocol NUXButtonViewControllerDelegate {
    func primaryButtonPressed()
    @objc optional func secondaryButtonPressed()
    @objc optional func tertiaryButtonPressed()
}

private struct NUXButtonConfig {
    typealias CallBackType = () -> Void

    let title: String?
    let attributedTitle: NSAttributedString?
    let socialService: SocialServiceName?
    let isPrimary: Bool
    let configureBodyFontForTitle: Bool?
    let accessibilityIdentifier: String?
    let callback: CallBackType?

    init(title: String? = nil, attributedTitle: NSAttributedString? = nil, socialService: SocialServiceName? = nil, isPrimary: Bool, configureBodyFontForTitle: Bool? = nil, accessibilityIdentifier: String? = nil, callback: CallBackType?) {
        self.title = title
        self.attributedTitle = attributedTitle
        self.socialService = socialService
        self.isPrimary = isPrimary
        self.configureBodyFontForTitle = configureBodyFontForTitle
        self.accessibilityIdentifier = accessibilityIdentifier
        self.callback = callback
    }
}

open class NUXButtonViewController: UIViewController {
    typealias CallBackType = () -> Void

    // MARK: - Properties

    @IBOutlet private var shadowView: UIImageView?
    @IBOutlet var stackView: UIStackView?
    @IBOutlet var bottomButton: NUXButton?
    @IBOutlet var topButton: NUXButton?
    @IBOutlet var tertiaryButton: NUXButton?
    @IBOutlet var buttonHolder: UIView?

    open var delegate: NUXButtonViewControllerDelegate?
    open var backgroundColor: UIColor?

    private var topButtonConfig: NUXButtonConfig?
    private var bottomButtonConfig: NUXButtonConfig?
    private var tertiaryButtonConfig: NUXButtonConfig?

    private let style = WordPressAuthenticator.shared.style

    // MARK: - View

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false

        shadowView?.image = style.buttonViewTopShadowImage
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configure(button: bottomButton, withConfig: bottomButtonConfig)
        configure(button: topButton, withConfig: topButtonConfig)
        configure(button: tertiaryButton, withConfig: tertiaryButtonConfig)
        
        buttonHolder?.backgroundColor = backgroundColor
    }

    private func configure(button: NUXButton?, withConfig buttonConfig: NUXButtonConfig?) {
        if let buttonConfig = buttonConfig, let button = button {
            
            if let attributedTitle = buttonConfig.attributedTitle {
                button.setAttributedTitle(attributedTitle, for: .normal)
                button.socialService = buttonConfig.socialService
            } else {
                button.setTitle(buttonConfig.title, for: .normal)
            }

            button.accessibilityIdentifier = buttonConfig.accessibilityIdentifier ?? accessibilityIdentifier(for: buttonConfig.title)
            button.isPrimary = buttonConfig.isPrimary
            if buttonConfig.configureBodyFontForTitle == true {
                button.customizeFont(WPStyleGuide.mediumWeightFont(forStyle: .body))
            }

            button.isHidden = false
        } else {
            button?.isHidden = true
        }
    }

    // MARK: public API

    /// Public method to set the button titles.
    ///
    /// - Parameters:
    ///   - primary: Title string for primary button. Required.
    ///   - primaryAccessibilityId: Accessibility identifier string for primary button. Optional.
    ///   - secondary: Title string for secondary button. Optional.
    ///   - secondaryAccessibilityId: Accessibility identifier string for secondary button. Optional.
    ///   - tertiary: Title string for the tertiary button. Optional.
    ///   - tertiaryAccessibilityId: Accessibility identifier string for tertiary button. Optional.
    ///
    public func setButtonTitles(primary: String, primaryAccessibilityId: String? = nil, secondary: String? = nil, secondaryAccessibilityId: String? = nil, tertiary: String? = nil, tertiaryAccessibilityId: String? = nil) {
        bottomButtonConfig = NUXButtonConfig(title: primary, isPrimary: true, accessibilityIdentifier: primaryAccessibilityId, callback: nil)
        if let secondaryTitle = secondary {
            topButtonConfig = NUXButtonConfig(title: secondaryTitle, isPrimary: false, accessibilityIdentifier: secondaryAccessibilityId, callback: nil)
        }
        if let tertiaryTitle = tertiary {
            tertiaryButtonConfig = NUXButtonConfig(title: tertiaryTitle, isPrimary: false, accessibilityIdentifier: tertiaryAccessibilityId, callback: nil)
        }
    }

    func setupTopButton(title: String, isPrimary: Bool = false, configureBodyFontForTitle: Bool = false, accessibilityIdentifier: String? = nil, onTap callback: @escaping CallBackType) {
        topButtonConfig = NUXButtonConfig(title: title, isPrimary: isPrimary, configureBodyFontForTitle: configureBodyFontForTitle, accessibilityIdentifier: accessibilityIdentifier, callback: callback)
    }

    func setupTopButtonFor(socialService: SocialServiceName, onTap callback: @escaping CallBackType) {
        topButtonConfig = buttonConfigFor(socialService: socialService, onTap: callback)
    }
    
    func setupBottomButton(title: String, isPrimary: Bool = false, configureBodyFontForTitle: Bool = false, accessibilityIdentifier: String? = nil, onTap callback: @escaping CallBackType) {
        bottomButtonConfig = NUXButtonConfig(title: title, isPrimary: isPrimary, configureBodyFontForTitle: configureBodyFontForTitle, accessibilityIdentifier: accessibilityIdentifier, callback: callback)
    }

    func setupButtomButtonFor(socialService: SocialServiceName, onTap callback: @escaping CallBackType) {
        bottomButtonConfig = buttonConfigFor(socialService: socialService, onTap: callback)
    }

    func setupTertiaryButton(title: String, isPrimary: Bool = false, accessibilityIdentifier: String? = nil, onTap callback: @escaping CallBackType) {
        tertiaryButton?.isHidden = false
        tertiaryButtonConfig = NUXButtonConfig(title: title, isPrimary: isPrimary, accessibilityIdentifier: accessibilityIdentifier, callback: callback)
    }

    func setupTertiaryButtonFor(socialService: SocialServiceName, onTap callback: @escaping CallBackType) {
        tertiaryButtonConfig = buttonConfigFor(socialService: socialService, onTap: callback)
    }

    func hideShadowView() {
        shadowView?.isHidden = true
    }

    // MARK: - Helpers

    private func buttonConfigFor(socialService: SocialServiceName, onTap callback: @escaping CallBackType) -> NUXButtonConfig {

        var attributedTitle = NSAttributedString()
        var accessibilityIdentifier = String()

        switch socialService {
        case .google:
            attributedTitle = WPStyleGuide.formattedGoogleString()
            accessibilityIdentifier = "Continue with Google Button"
        case .apple:
            attributedTitle = WPStyleGuide.formattedAppleString()
            accessibilityIdentifier = "Continue with Apple Button"
        }

        return NUXButtonConfig(attributedTitle: attributedTitle,
                               socialService: socialService,
                               isPrimary: false,
                               accessibilityIdentifier: accessibilityIdentifier,
                               callback: callback)
    }

    private func accessibilityIdentifier(for string: String?) -> String {
        return "\(string ?? "") Button"
    }

    // MARK: - Button Handling

    @IBAction func primaryButtonPressed(_ sender: Any) {
        guard let callback = bottomButtonConfig?.callback else {
            delegate?.primaryButtonPressed()
            return
        }
        callback()
    }

    @IBAction func secondaryButtonPressed(_ sender: Any) {
        guard let callback = topButtonConfig?.callback else {
            delegate?.secondaryButtonPressed?()
            return
        }
        callback()
    }

    @IBAction func tertiaryButtonPressed(_ sender: Any) {
        guard let callback = tertiaryButtonConfig?.callback else {
            delegate?.tertiaryButtonPressed?()
            return
        }
        callback()
    }

    // MARK: - Dynamic type

    func didChangePreferredContentSize() {
        configure(button: bottomButton, withConfig: bottomButtonConfig)
        configure(button: topButton, withConfig: topButtonConfig)
        configure(button: tertiaryButton, withConfig: tertiaryButtonConfig)
    }
}

extension NUXButtonViewController {
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            didChangePreferredContentSize()
        }
    }
}

extension NUXButtonViewController {

    /// Sets the parentViewControlleras the receiver instance's container. Plus: the containerView will also get the receiver's
    /// view, attached to it's edges. This is effectively analog to using an Embed Segue with the NUXButtonViewController.
    ///
    public func move(to parentViewController: UIViewController, into containerView: UIView) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        containerView.pinSubviewToAllEdges(view)

        willMove(toParent: parentViewController)
        parentViewController.addChild(self)
        didMove(toParent: parentViewController)
    }

    /// Returns a new NUXButtonViewController Instance
    ///
    public class func instance() -> NUXButtonViewController {
        let storyboard = UIStoryboard(name: "NUXButtonView", bundle: WordPressAuthenticator.bundle)
        guard let buttonViewController = storyboard.instantiateViewController(withIdentifier: "ButtonView") as? NUXButtonViewController else {
            fatalError()
        }

        return buttonViewController
    }
}
