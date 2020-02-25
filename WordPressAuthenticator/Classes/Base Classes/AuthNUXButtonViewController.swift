import UIKit

@objc public protocol AuthNUXButtonViewControllerDelegate {
    func primaryButtonPressed()
    @objc optional func secondaryButtonPressed()
    @objc optional func tertiaryButtonPressed()
}

private struct AuthNUXButtonConfig {
    typealias CallBackType = () -> Void

    let title: String
    let isPrimary: Bool
    let accessibilityIdentifier: String?
    let callback: CallBackType?

    init(title: String, isPrimary: Bool, accessibilityIdentifier: String? = nil, callback: CallBackType?) {
        self.title = title
        self.isPrimary = isPrimary
        self.accessibilityIdentifier = accessibilityIdentifier
        self.callback = callback
    }
}

open class AuthNUXButtonViewController: UIViewController {
    typealias CallBackType = () -> Void

    // MARK: - Properties

    @IBOutlet var shadowView: UIView?
    @IBOutlet var stackView: UIStackView?
    @IBOutlet var bottomButton: AuthNUXButton?
    @IBOutlet var topButton: AuthNUXButton?
    @IBOutlet var tertiaryButton: AuthNUXButton?
    @IBOutlet var buttonHolder: UIView?

    open var delegate: AuthNUXButtonViewControllerDelegate?
    open var backgroundColor: UIColor?

    private var topButtonConfig: AuthNUXButtonConfig?
    private var bottomButtonConfig: AuthNUXButtonConfig?
    private var tertiaryButtonConfig: AuthNUXButtonConfig?

    // MARK: - View

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configure(button: bottomButton, withConfig: bottomButtonConfig)
        configure(button: topButton, withConfig: topButtonConfig)
        configure(button: tertiaryButton, withConfig: tertiaryButtonConfig)
        if let bgColor = backgroundColor, let holder = buttonHolder {
            holder.backgroundColor = bgColor
        }
    }

    private func configure(button: AuthNUXButton?, withConfig buttonConfig: AuthNUXButtonConfig?) {
        if let buttonConfig = buttonConfig, let button = button {
            button.setTitle(buttonConfig.title, for: .normal)
            button.accessibilityIdentifier = buttonConfig.accessibilityIdentifier ?? accessibilityIdentifier(for: buttonConfig.title)
            button.isPrimary = buttonConfig.isPrimary
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
        bottomButtonConfig = AuthNUXButtonConfig(title: primary, isPrimary: true, accessibilityIdentifier: primaryAccessibilityId, callback: nil)
        if let secondaryTitle = secondary {
            topButtonConfig = AuthNUXButtonConfig(title: secondaryTitle, isPrimary: false, accessibilityIdentifier: secondaryAccessibilityId, callback: nil)
        }
        if let tertiaryTitle = tertiary {
            tertiaryButtonConfig = AuthNUXButtonConfig(title: tertiaryTitle, isPrimary: false, accessibilityIdentifier: tertiaryAccessibilityId, callback: nil)
        }
    }

    func setupTopButton(title: String, isPrimary: Bool = false, accessibilityIdentifier: String? = nil, onTap callback: @escaping CallBackType) {
        topButtonConfig = AuthNUXButtonConfig(title: title, isPrimary: isPrimary, accessibilityIdentifier: accessibilityIdentifier, callback: callback)
    }

    func setupBottomButton(title: String, isPrimary: Bool = false, accessibilityIdentifier: String? = nil, onTap callback: @escaping CallBackType) {
        bottomButtonConfig = AuthNUXButtonConfig(title: title, isPrimary: isPrimary, accessibilityIdentifier: accessibilityIdentifier, callback: callback)
    }

    func setupTertiaryButton(title: String, isPrimary: Bool = false, accessibilityIdentifier: String? = nil, onTap callback: @escaping CallBackType) {
        tertiaryButton?.isHidden = false
        tertiaryButtonConfig = AuthNUXButtonConfig(title: title, isPrimary: isPrimary, accessibilityIdentifier: accessibilityIdentifier, callback: callback)
    }

    // MARK: - Helpers

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

extension AuthNUXButtonViewController {
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            didChangePreferredContentSize()
        }
    }
}

extension AuthNUXButtonViewController {

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
    public class func instance() -> AuthNUXButtonViewController {
        let storyboard = UIStoryboard(name: "NUXButtonView", bundle: WordPressAuthenticator.bundle)
        guard let buttonViewController = storyboard.instantiateViewController(withIdentifier: "ButtonView") as? AuthNUXButtonViewController else {
            fatalError()
        }

        return buttonViewController
    }
}
