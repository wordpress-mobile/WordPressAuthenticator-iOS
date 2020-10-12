import UIKit
import Lottie
import WordPressShared
import WordPressUI
import WordPressKit

class LoginPrologueViewController: LoginViewController {

    @IBOutlet private weak var topContainerView: UIView!
    @IBOutlet private weak var buttonContainerView: UIView!
    @IBOutlet private weak var buttonBlurEffectView: UIVisualEffectView!
    private var buttonViewController: NUXButtonViewController?
    var showCancel = false

    /// Blur effect on button container view
    ///
    private var blurEffect: UIBlurEffect.Style {
        if #available(iOS 13.0, *) {
            return .systemChromeMaterial
        }

        return .regular
    }

    /// Constraints on the button view container.
    /// Used to adjust the button width in unified views.
    @IBOutlet private weak var buttonViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonViewTrailingConstraint: NSLayoutConstraint!
    private var defaultButtonViewMargin: CGFloat = 0

    /// Constraint on the top view container.
    /// Used to adjust the top view for unified prologue carousel
    @IBOutlet private weak var topContainerBottomConstraint: NSLayoutConstraint!

    // Called when login button is tapped
    var onLoginButtonTapped: (() -> Void)?

    private let configuration = WordPressAuthenticator.shared.configuration
    private let style = WordPressAuthenticator.shared.style

    @available(iOS 13, *)
    private lazy var storedCredentialsAuthenticator = StoredCredentialsAuthenticator(onCancel: {
        // Since the authenticator has its own flow
        self.tracker.resetState()
    })

    /// We can't rely on `isMovingToParent` to know if we need to track the `.prologue` step
    /// because for the root view in an App, it's always `false`.  We're relying this variiable
    /// instead, since the `.prologue` step only needs to be tracked once.
    ///
    private var prologueFlowTracked = false

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        if WordPressAuthenticator.shared.configuration.enableUnifiedCarousel {
            // extend the top container behind the button container
            topContainerBottomConstraint.constant = 0
        } else {
            topContainerBottomConstraint.constant = -buttonContainerView.frame.height
        }

        if let topContainerChildViewController = style.prologueTopContainerChildViewController() {
            topContainerView.subviews.forEach { $0.removeFromSuperview() }
            addChild(topContainerChildViewController)
            topContainerView.addSubview(topContainerChildViewController.view)
            topContainerChildViewController.didMove(toParent: self)

            topContainerChildViewController.view.translatesAutoresizingMaskIntoConstraints = false
            topContainerView.pinSubviewToAllEdges(topContainerChildViewController.view)
        }
        
        defaultButtonViewMargin = buttonViewLeadingConstraint?.constant ?? 0
    }

    override func styleBackground() {
        guard let unifiedBackgroundColor = WordPressAuthenticator.shared.unifiedStyle?.viewControllerBackgroundColor else {
            super.styleBackground()
            return
        }
        
        view.backgroundColor = unifiedBackgroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureButtonVC()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // We've found some instances where the iCloud Keychain login flow was being started
        // when the device was idle and the app was logged out and in the background.  I couldn't
        // find precise reproduction steps for this issue but my guess is that some background
        // operation is triggering a call to this method while the app is in the background.
        // The proposed solution is based off this StackOverflow reply:
        //
        // https://stackoverflow.com/questions/30584356/viewdidappear-is-called-when-app-is-started-due-to-significant-location-change
        //
        guard UIApplication.shared.applicationState != .background else {
            return
        }
        
        WordPressAuthenticator.track(.loginPrologueViewed)

        tracker.set(flow: .prologue)
        
        if isBeingPresentedInAnyWay {
            tracker.track(step: .prologue)
        } else {
            tracker.set(step: .prologue)
        }
        
        showiCloudKeychainLoginFlow()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.isPad() ? .all : .portrait
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setButtonViewMargins(forWidth: view.frame.width)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setButtonViewMargins(forWidth: size.width)
    }
    
    // MARK: - iCloud Keychain Login
    
    /// Starts the iCloud Keychain login flow if the conditions are given.
    ///
    private func showiCloudKeychainLoginFlow() {
        guard #available(iOS 13, *),
            WordPressAuthenticator.shared.configuration.enableUnifiedAuth,
            let navigationController = navigationController else {
                return
        }

        storedCredentialsAuthenticator.showPicker(from: navigationController)
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let vc = segue.destination as? NUXButtonViewController {
            buttonViewController = vc
        }
    }

    private func configureButtonVC() {
        guard let buttonViewController = buttonViewController else {
            return
        }

        guard configuration.enableUnifiedAuth else {
            buildPrologueButtons(buttonViewController)
            return
        }

        buildUnifiedPrologueButtons(buttonViewController)
    }

    /// Displays the old UI prologue buttons.
    ///
    private func buildPrologueButtons(_ buttonViewController: NUXButtonViewController) {
        let loginTitle = NSLocalizedString("Log In", comment: "Button title.  Tapping takes the user to the login form.")
        let createTitle = NSLocalizedString("Sign up for WordPress.com", comment: "Button title. Tapping begins the process of creating a WordPress.com account.")

        buttonViewController.setupTopButton(title: loginTitle, isPrimary: false, accessibilityIdentifier: "Prologue Log In Button") { [weak self] in
            self?.onLoginButtonTapped?()
            self?.loginTapped()
        }

        if configuration.enableSignUp {
            buttonViewController.setupBottomButton(title: createTitle, isPrimary: true, accessibilityIdentifier: "Prologue Signup Button") { [weak self] in
                self?.signupTapped()
            }
        }

        if showCancel {
            let cancelTitle = NSLocalizedString("Cancel", comment: "Button title. Tapping it cancels the login flow.")
            buttonViewController.setupTertiaryButton(title: cancelTitle, isPrimary: false) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }

        buttonViewController.backgroundColor = style.buttonViewBackgroundColor
        buttonBlurEffectView.isHidden = true
    }

    /// Displays the Unified prologue buttons.
    ///
    private func buildUnifiedPrologueButtons(_ buttonViewController: NUXButtonViewController) {
        let loginTitle = NSLocalizedString("Continue with WordPress.com",
                                           comment: "Button title. Takes the user to the login by email flow.")
        let siteAddressTitle = NSLocalizedString("Enter your site address",
                                                 comment: "Button title. Takes the user to the login by site address flow.")

        setButtonViewMargins(forWidth: view.frame.width)
        
        buttonViewController.setupTopButton(title: loginTitle, isPrimary: true, accessibilityIdentifier: "Prologue Continue Button") { [weak self] in
            guard let self = self else {
                return
            }
            
            self.tracker.track(click: .continueWithWordPressCom)
            self.continueWithDotCom()
        }

        if configuration.enableUnifiedAuth {
            buttonViewController.setupBottomButton(title: siteAddressTitle, isPrimary: false, accessibilityIdentifier: "Prologue Self Hosted Button") { [weak self] in
                self?.siteAddressTapped()
            }
        }

        if showCancel {
            let cancelTitle = NSLocalizedString("Cancel", comment: "Button title. Tapping it cancels the login flow.")
            buttonViewController.setupTertiaryButton(title: cancelTitle, isPrimary: false) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }

        // Set the button background color to clear so the blur effect blurs the Prologue background color.
        buttonViewController.backgroundColor = .clear
        buttonBlurEffectView.effect = UIBlurEffect(style: blurEffect)
    }

    // MARK: - Actions

    /// Old UI. "Log In" button action.
    ///
    private func loginTapped() {
        tracker.set(source: .default)

        guard let vc = LoginPrologueLoginMethodViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate to LoginPrologueLoginMethodViewController from LoginPrologueViewController")
            return
        }

        vc.transitioningDelegate = self

        // Continue with WordPress.com button action
        vc.emailTapped = { [weak self] in
            guard let self = self else {
                return
            }

            self.presentLoginEmailView()
        }

        // Continue with Google button action
        vc.googleTapped = { [weak self] in
            self?.googleTapped()
        }

        // Site address text link button action
        vc.selfHostedTapped = { [weak self] in
            self?.loginToSelfHostedSite()
        }

        // Sign In With Apple (SIWA) button action
        vc.appleTapped = { [weak self] in
            self?.appleTapped()
        }

        vc.modalPresentationStyle = .custom
        navigationController?.present(vc, animated: true, completion: nil)
    }

    /// Old UI. "Sign up with WordPress.com" button action.
    ///
    private func signupTapped() {
        tracker.set(source: .default)
        
        // This stat is part of a funnel that provides critical information.
        // Before making ANY modification to this stat please refer to: p4qSXL-35X-p2
        WordPressAuthenticator.track(.signupButtonTapped)

        guard let vc = LoginPrologueSignupMethodViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate to LoginPrologueSignupMethodViewController")
            return
        }

        vc.loginFields = self.loginFields
        vc.dismissBlock = dismissBlock
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom

        vc.emailTapped = { [weak self] in
            guard let self = self else {
                return
            }

            guard self.configuration.enableUnifiedAuth else {
                self.presentSignUpEmailView()
                return
            }

            self.presentUnifiedSignupView()
        }

        vc.googleTapped = { [weak self] in
            guard let self = self else {
                return
            }
            
            guard self.configuration.enableUnifiedAuth else {
                self.presentGoogleSignupView()
                return
            }

            self.presentUnifiedGoogleView()
        }

        vc.appleTapped = { [weak self] in
            self?.appleTapped()
        }

        navigationController?.present(vc, animated: true, completion: nil)
    }

    private func appleTapped() {
        AppleAuthenticator.sharedInstance.delegate = self
        AppleAuthenticator.sharedInstance.showFrom(viewController: self)
    }

    private func googleTapped() {
        guard configuration.enableUnifiedAuth else {
            GoogleAuthenticator.sharedInstance.loginDelegate = self
            GoogleAuthenticator.sharedInstance.showFrom(viewController: self, loginFields: loginFields, for: .login)
            return
        }
        
        presentUnifiedGoogleView()
    }

    /// Unified "Continue with WordPress.com" prologue button action.
    ///
    private func continueWithDotCom() {
        guard let vc = GetStartedViewController.instantiate(from: .getStarted) else {
            DDLogError("Failed to navigate from LoginPrologueViewController to GetStartedViewController")
            return
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    /// Unified "Enter your site address" prologue button action.
    ///
    private func siteAddressTapped() {
        tracker.track(click: .loginWithSiteAddress)

        loginToSelfHostedSite()
    }

    private func presentSignUpEmailView() {
        guard let toVC = SignupEmailViewController.instantiate(from: .signup) else {
            DDLogError("Failed to navigate to SignupEmailViewController")
            return
        }

        navigationController?.pushViewController(toVC, animated: true)
    }

    private func presentUnifiedSignupView() {
        guard let toVC = UnifiedSignupViewController.instantiate(from: .unifiedSignup) else {
            DDLogError("Failed to navigate to UnifiedSignupViewController")
            return
        }

        navigationController?.pushViewController(toVC, animated: true)
    }

    private func presentLoginEmailView() {
        guard let toVC = LoginEmailViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate to LoginEmailVC from LoginPrologueVC")
            return
        }

        navigationController?.pushViewController(toVC, animated: true)
    }

    private func presentGetStartedView() {
        guard let toVC = GetStartedViewController.instantiate(from: .getStarted) else {
            DDLogError("Failed to navigate to GetStartedViewController")
            return
        }

        navigationController?.pushViewController(toVC, animated: true)
    }

    // Shows the VC that handles both Google login & signup.
    private func presentUnifiedGoogleView() {
        guard let toVC = GoogleAuthViewController.instantiate(from: .googleAuth) else {
            DDLogError("Failed to navigate to GoogleAuthViewController from LoginPrologueVC")
            return
        }
        
        navigationController?.pushViewController(toVC, animated: true)
    }

    // Shows the VC that handles only Google signup.
    private func presentGoogleSignupView() {
        guard let toVC = SignupGoogleViewController.instantiate(from: .signup) else {
            DDLogError("Failed to navigate to SignupGoogleViewController from LoginPrologueVC")
            return
        }

        navigationController?.pushViewController(toVC, animated: true)
    }

    private func presentWPLogin() {
        guard let vc = LoginWPComViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate from LoginPrologueViewController to LoginWPComViewController")
            return
        }
        
        vc.loginFields = self.loginFields
        vc.dismissBlock = dismissBlock
        vc.errorToPresent = errorToPresent
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentUnifiedPassword() {
        guard let vc = PasswordViewController.instantiate(from: .password) else {
            DDLogError("Failed to navigate from LoginPrologueViewController to PasswordViewController")
            return
        }
        
        vc.loginFields = loginFields
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - LoginFacadeDelegate

extension LoginPrologueViewController {

    // Used by SIWA when logging with with a passwordless, 2FA account.
    //
    func needsMultifactorCode(forUserID userID: Int, andNonceInfo nonceInfo: SocialLogin2FANonceInfo) {
        configureViewLoading(false)
        socialNeedsMultifactorCode(forUserID: userID, andNonceInfo: nonceInfo)
    }

}

// MARK: - AppleAuthenticatorDelegate

extension LoginPrologueViewController: AppleAuthenticatorDelegate {

    func showWPComLogin(loginFields: LoginFields) {
        self.loginFields = loginFields

        guard WordPressAuthenticator.shared.configuration.enableUnifiedAuth else {
            presentWPLogin()
            return
        }

        presentUnifiedPassword()
    }

    func showApple2FA(loginFields: LoginFields) {
        self.loginFields = loginFields
        signInAppleAccount()
    }
    
    func authFailedWithError(message: String) {
        displayErrorAlert(message, sourceTag: .loginApple)
    }

}

// MARK: - GoogleAuthenticatorLoginDelegate

extension LoginPrologueViewController: GoogleAuthenticatorLoginDelegate {

    func googleFinishedLogin(credentials: AuthenticatorCredentials, loginFields: LoginFields) {
        self.loginFields = loginFields
        syncWPComAndPresentEpilogue(credentials: credentials)
    }

    func googleNeedsMultifactorCode(loginFields: LoginFields) {
        self.loginFields = loginFields

        guard let vc = Login2FAViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate from LoginViewController to Login2FAViewController")
            return
        }

        vc.loginFields = loginFields
        vc.dismissBlock = dismissBlock
        vc.errorToPresent = errorToPresent

        navigationController?.pushViewController(vc, animated: true)
    }

    func googleExistingUserNeedsConnection(loginFields: LoginFields) {
        self.loginFields = loginFields

        guard let vc = LoginWPComViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate from Google Login to LoginWPComViewController (password VC)")
            return
        }

        vc.loginFields = loginFields
        vc.dismissBlock = dismissBlock
        vc.errorToPresent = errorToPresent

        navigationController?.pushViewController(vc, animated: true)
    }

    func googleLoginFailed(errorTitle: String, errorDescription: String, loginFields: LoginFields) {
        self.loginFields = loginFields

        let socialErrorVC = LoginSocialErrorViewController(title: errorTitle, description: errorDescription)
        let socialErrorNav = LoginNavigationController(rootViewController: socialErrorVC)
        socialErrorVC.delegate = self
        socialErrorVC.loginFields = loginFields
        socialErrorVC.modalPresentationStyle = .fullScreen
        present(socialErrorNav, animated: true)
    }

}

// MARK: - Button View Sizing

private extension LoginPrologueViewController {

    /// Resize the button view based on trait collection.
    /// Used only in unified views.
    ///
    func setButtonViewMargins(forWidth viewWidth: CGFloat) {
        
        guard configuration.enableUnifiedAuth else {
            return
        }
        
        guard traitCollection.horizontalSizeClass == .regular &&
            traitCollection.verticalSizeClass == .regular else {
                buttonViewLeadingConstraint.constant = defaultButtonViewMargin
                buttonViewTrailingConstraint.constant = defaultButtonViewMargin
                return
        }
        
        let marginMultiplier = UIDevice.current.orientation.isLandscape ?
            ButtonViewMarginMultipliers.ipadLandscape :
            ButtonViewMarginMultipliers.ipadPortrait
        
        let margin = viewWidth * marginMultiplier
        
        buttonViewLeadingConstraint.constant = margin
        buttonViewTrailingConstraint.constant = margin
    }
    
    private enum ButtonViewMarginMultipliers {
        static let ipadPortrait: CGFloat = 0.1667
        static let ipadLandscape: CGFloat = 0.25
    }

}
