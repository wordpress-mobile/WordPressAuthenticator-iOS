import WordPressUI


// MARK: - NUXViewController
/// Base class to use for NUX view controllers that aren't a table view
/// Note: shares most of its code with NUXTableViewController and NUXCollectionViewController. Look to make
///       most changes in either the base protocol NUXViewControllerBase or further subclasses like LoginViewController
open class NUXViewController: UIViewController, NUXViewControllerBase, UIViewControllerTransitioningDelegate {
    // MARK: NUXViewControllerBase properties
    /// these properties comply with NUXViewControllerBase and are duplicated with NUXTableViewController
    public var helpNotificationIndicator: WPHelpIndicatorView = WPHelpIndicatorView()
    public var helpButton: UIButton = UIButton(type: .custom)
    public var dismissBlock: ((_ cancelled: Bool) -> Void)?
    public var loginFields = LoginFields()
    open var sourceTag: WordPressSupportSourceTag {
        get {
            return .generalLogin
        }
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.isPad() ? .all : .portrait
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupHelpButtonIfNeeded()
        setupCancelButtonIfNeeded()
        setupBackgroundTapGestureRecognizer()
    }

    // properties specific to NUXViewController
    @IBOutlet var submitButton: NUXButton?
    @IBOutlet var errorLabel: UILabel?

    func configureSubmitButton(animating: Bool) {
        submitButton?.showActivityIndicator(animating)
        submitButton?.isEnabled = enableSubmit(animating: animating)
    }

    /// Localize the "Continue" button.
    ///
    func localizePrimaryButton() {
        let primaryTitle = WordPressAuthenticator.shared.displayStrings.continueButtonTitle
        submitButton?.setTitle(primaryTitle, for: .normal)
        submitButton?.setTitle(primaryTitle, for: .highlighted)
    }
    
    open func enableSubmit(animating: Bool) -> Bool {
        return !animating
    }

    public func shouldShowCancelButton() -> Bool {
        return shouldShowCancelButtonBase()
    }
}

extension NUXViewController {
    // Required so that any FancyAlertViewControllers presented within the NUX
    // use the correct dimmed backing view.
    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is FancyAlertViewController ||
            presented is LoginPrologueSignupMethodViewController ||
            presented is LoginPrologueLoginMethodViewController {
            return FancyAlertPresentationController(presentedViewController: presented, presenting: presenting)
        }

        return nil
    }
}
