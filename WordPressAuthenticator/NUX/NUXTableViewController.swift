// MARK: - NUXTableViewController
/// Base class to use for NUX view controllers that are also a table view controller
/// Note: shares most of its code with NUXViewController.
open class NUXTableViewController: UITableViewController, NUXViewControllerBase, UIViewControllerTransitioningDelegate {
    // MARK: NUXViewControllerBase properties
    /// these properties comply with NUXViewControllerBase and are duplicated with NUXViewController
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
    }

    deinit {
        removeNotificationObservers()
    }

    public func shouldShowCancelButton() -> Bool {
        return shouldShowCancelButtonBase()
    }
}
