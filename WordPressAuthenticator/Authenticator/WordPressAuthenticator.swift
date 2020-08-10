import UIKit
import CocoaLumberjack
import NSURL_IDN
import GoogleSignIn
import WordPressShared
import WordPressUI
import AuthenticationServices


import WordPressKit
final class SignInMethodsCoordinator: NSObject {
    private var loginFields = LoginFields()
    private var error: Error?

    private lazy var loginFacade: LoginFacade = {
        let configuration = WordPressAuthenticator.shared.configuration
        let facade = LoginFacade(dotcomClientID: configuration.wpcomClientId,
                                 dotcomSecret: configuration.wpcomSecret,
                                 userAgent: configuration.userAgent)
        facade.delegate = self
        return facade
    }()

    private let presenter: UIViewController
    private var authenticationDelegate: WordPressAuthenticatorDelegate {
        guard let delegate = WordPressAuthenticator.shared.delegate else {
            fatalError()
        }

        return delegate
    }

    private var isSignUp: Bool {
        loginFields.meta.emailMagicLinkSource == .signup
    }

    private var isJetpackLogin: Bool {
        return loginFields.meta.jetpackLogin
    }

    private let onDismiss: ((_ cancelled: Bool) -> Void)?

    init(presenter: UIViewController, onDismiss: ((_ cancelled: Bool) -> Void)?) {
        self.presenter = presenter
        self.onDismiss = onDismiss
    }
}

extension SignInMethodsCoordinator: LoginFacadeDelegate {

}

extension SignInMethodsCoordinator: AppleAuthenticatorDelegate {
    func showWPComLogin(loginFields: LoginFields) {
        self.loginFields = loginFields

        guard let vc = LoginWPComViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate from LoginEmailViewController to LoginWPComViewController")
            return
        }

        vc.loginFields = self.loginFields
        vc.dismissBlock = onDismiss
        vc.errorToPresent = error

        presenter.navigationController?.pushViewController(vc, animated: true)
    }

    func showApple2FA(loginFields: LoginFields) {
        self.loginFields = loginFields
        signInAppleAccount()
    }

    func authFailedWithError(message: String) {
        displayErrorAlert(message, sourceTag: .loginApple)
    }
}

private extension SignInMethodsCoordinator {
    func signInAppleAccount() {
        guard let token = loginFields.meta.socialServiceIDToken else {
            WordPressAuthenticator.track(.loginSocialButtonFailure, properties: ["source": SocialServiceName.apple.rawValue])
            configureViewLoading(false)
            return
        }

        loginFacade.loginToWordPressDotCom(withSocialIDToken: token, service: SocialServiceName.apple.rawValue)
    }

    /// Sets the view's state to loading or not loading.
    ///
    /// - Parameter loading: True if the form should be configured to a "loading" state.
    ///
    func configureViewLoading(_ loading: Bool) {
//        emailTextField.isEnabled = !loading
//        googleLoginButton?.isEnabled = !loading
//
//        submitButton?.isEnabled = !loading
//        submitButton?.showActivityIndicator(loading)
    }

    /// Displays a login error message in an attractive dialog
    ///
    func displayErrorAlert(_ message: String, sourceTag: WordPressSupportSourceTag) {
        let presentingController = presenter.navigationController ?? presenter
        let controller = FancyAlertViewController.alertForGenericErrorMessageWithHelpButton(message, loginFields: loginFields, sourceTag: sourceTag)
        controller.modalPresentationStyle = .custom
//        controller.transitioningDelegate = self
        presentingController.present(controller, animated: true, completion: nil)
    }
}

// MARK: - GoogleAuthenticatorLoginDelegate

extension SignInMethodsCoordinator: GoogleAuthenticatorLoginDelegate {

    func googleFinishedLogin(credentials: AuthenticatorCredentials, loginFields: LoginFields) {
        self.loginFields = loginFields
        syncWPComAndPresentEpilogue(credentials: credentials)
    }

    func googleNeedsMultifactorCode(loginFields: LoginFields) {
        self.loginFields = loginFields
        configureViewLoading(false)

        guard let vc = Login2FAViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate from LoginViewController to Login2FAViewController")
            return
        }

        vc.loginFields = loginFields
        vc.dismissBlock = onDismiss
        vc.errorToPresent = error

        presenter.navigationController?.pushViewController(vc, animated: true)
    }

    func googleExistingUserNeedsConnection(loginFields: LoginFields) {
        self.loginFields = loginFields
        configureViewLoading(false)

        guard let vc = LoginWPComViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate from Google Login to LoginWPComViewController (password VC)")
            return
        }

        vc.loginFields = loginFields
        vc.dismissBlock = onDismiss
        vc.errorToPresent = error

        presenter.navigationController?.pushViewController(vc, animated: true)
    }

    func googleLoginFailed(errorTitle: String, errorDescription: String, loginFields: LoginFields) {
        self.loginFields = loginFields
        configureViewLoading(false)

        let socialErrorVC = LoginSocialErrorViewController(title: errorTitle, description: errorDescription)
        let socialErrorNav = LoginNavigationController(rootViewController: socialErrorVC)
        socialErrorVC.delegate = self
        socialErrorVC.loginFields = loginFields
        socialErrorVC.modalPresentationStyle = .fullScreen
        presenter.present(socialErrorNav, animated: true)
    }

    /// Signals the Main App to synchronize the specified WordPress.com account. On completion, the epilogue will be pushed (if needed).
    ///
    private func syncWPComAndPresentEpilogue(credentials: AuthenticatorCredentials) {
        syncWPCom(credentials: credentials) { [weak self] in
            guard let self = self else {
                return
            }

            if self.mustShowSignupEpilogue() {
                self.showSignupEpilogue(for: credentials)
            } else if self.mustShowLoginEpilogue() {
                self.showLoginEpilogue(for: credentials)
            } else {
                self.dismiss()
            }
        }
    }

    private func mustShowLoginEpilogue() -> Bool {
        return isSignUp == false && authenticationDelegate.shouldPresentLoginEpilogue(isJetpackLogin: isJetpackLogin)
    }

    private func mustShowSignupEpilogue() -> Bool {
        return isSignUp && authenticationDelegate.shouldPresentSignupEpilogue()
    }


    // MARK: - Epilogue

    func showSignupEpilogue(for credentials: AuthenticatorCredentials) {
        guard let navigationController = presenter.navigationController else {
            fatalError()
        }

        let service = loginFields.meta.googleUser.flatMap {
            return SocialService.google(user: $0)
        }

        authenticationDelegate.presentSignupEpilogue(in: navigationController, for: credentials, service: service)
    }

    func showLoginEpilogue(for credentials: AuthenticatorCredentials) {
        guard let navigationController = presenter.navigationController else {
            fatalError()
        }

        authenticationDelegate.presentLoginEpilogue(in: navigationController, for: credentials) { [weak self] in
            self?.onDismiss?(false)
        }
    }

    /// It is assumed that NUX view controllers are always presented modally.
    ///
    private func dismiss() {
        dismiss(cancelled: false)
    }

    /// It is assumed that NUX view controllers are always presented modally.
    /// This method dismisses the view controller
    ///
    /// - Parameters:
    ///     - cancelled: Should be passed true only when dismissed by a tap on the cancel button.
    ///
    private func dismiss(cancelled: Bool) {
        onDismiss?(cancelled)
        presenter.dismiss(animated: true, completion: nil)
    }

    /// TODO: @jlp Mar.19.2018. Officially support wporg, and rename to `sync(site)` + Update LoginSelfHostedViewController
    ///
    /// Signals the Main App to synchronize the specified WordPress.com account.
    ///
    private func syncWPCom(credentials: AuthenticatorCredentials, completion: (() -> ())? = nil) {
        SafariCredentialsService.updateSafariCredentialsIfNeeded(with: loginFields)

//        configureStatusLabel(LocalizedText.gettingAccountInfo)

        authenticationDelegate.sync(credentials: credentials) { [weak self] in

//            self?.configureStatusLabel("")
            self?.configureViewLoading(false)
            self?.trackSignIn(credentials: credentials)

            completion?()
        }
    }

    /// Tracks the SignIn Event
    ///
    private func trackSignIn(credentials: AuthenticatorCredentials) {
        var properties = [String: String]()

        if let wpcom = credentials.wpcom {
            properties = [
                "multifactor": wpcom.multifactor.description,
                "dotcom_user": true.description
            ]
        }

        WordPressAuthenticator.track(.signedIn, properties: properties)
    }
}

// MARK: - LoginSocialError delegate methods
extension SignInMethodsCoordinator: LoginSocialErrorViewControllerDelegate {
    private func cleanupAfterSocialErrors() {
        presenter.dismiss(animated: true)
    }

    /// Displays the self-hosted login form.
    ///
    private func loginToSelfHostedSite() {
        guard let vc = WordPressAuthenticator.signinForWPOrg() as? LoginSiteAddressViewController else {
            return
        }

        vc.loginFields = loginFields
        vc.dismissBlock = onDismiss
        vc.errorToPresent = error

        presenter.navigationController?.pushViewController(vc, animated: true)
    }

    func retryWithEmail() {
        loginFields.username = ""
        cleanupAfterSocialErrors()
    }

    func retryWithAddress() {
        cleanupAfterSocialErrors()
        loginToSelfHostedSite()
    }

    func retryAsSignup() {
        cleanupAfterSocialErrors()

        if let controller = SignupEmailViewController.instantiate(from: .signup) {
            controller.loginFields = loginFields
            presenter.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - WordPressAuthenticator: Public API to deal with WordPress.com and WordPress.org authentication.
//
@objc public class WordPressAuthenticator: NSObject {

    /// (Private) Shared Instance.
    ///
    private static var privateInstance: WordPressAuthenticator?

    /// Observer for AppleID Credential State
    ///
    private var appleIDCredentialObserver: NSObjectProtocol?

    /// Shared Instance.
    ///
    @objc public static var shared: WordPressAuthenticator {
        guard let privateInstance = privateInstance else {
            fatalError("WordPressAuthenticator wasn't initialized")
        }

        return privateInstance
    }

    /// Authenticator's Delegate.
    ///
    public weak var delegate: WordPressAuthenticatorDelegate?

    /// Authenticator's Configuration.
    ///
    public let configuration: WordPressAuthenticatorConfiguration

    /// Authenticator's Styles.
    ///
    public let style: WordPressAuthenticatorStyle

    /// Authenticator's Styles for unified flows.
    ///
    public let unifiedStyle: WordPressAuthenticatorUnifiedStyle?
    
    /// Authenticator's Display Images.
    ///
    public let displayImages: WordPressAuthenticatorDisplayImages

    /// Authenticator's Display Texts.
    ///
    public let displayStrings: WordPressAuthenticatorDisplayStrings
    
    /// Notification to be posted whenever the signing flow completes.
    ///
    @objc public static let WPSigninDidFinishNotification = "WPSigninDidFinishNotification"

    /// Internal Constants.
    ///
    private enum Constants {
        static let authenticationInfoKey    = "authenticationInfoKey"
        static let jetpackBlogXMLRPC        = "jetpackBlogXMLRPC"
        static let jetpackBlogUsername      = "jetpackBlogUsername"
        static let username                 = "username"
        static let emailMagicLinkSource     = "emailMagicLinkSource"
        static let magicLinkUrlPath         = "magic-login"
    }

    // MARK: - Initialization

    /// Designated Initializer
    ///
    private init(configuration: WordPressAuthenticatorConfiguration,
                 style: WordPressAuthenticatorStyle,
                 unifiedStyle: WordPressAuthenticatorUnifiedStyle?,
                 displayImages: WordPressAuthenticatorDisplayImages,
                 displayStrings: WordPressAuthenticatorDisplayStrings) {
        self.configuration = configuration
        self.style = style
        self.unifiedStyle = unifiedStyle
        self.displayImages = displayImages
        self.displayStrings = displayStrings
    }

    /// Initializes the WordPressAuthenticator with the specified Configuration.
    ///
    public static func initialize(configuration: WordPressAuthenticatorConfiguration,
                                  style: WordPressAuthenticatorStyle,
                                  unifiedStyle: WordPressAuthenticatorUnifiedStyle?,
                                  displayImages: WordPressAuthenticatorDisplayImages = .defaultImages,
                                  displayStrings: WordPressAuthenticatorDisplayStrings = .defaultStrings) {
        guard privateInstance == nil else {
            fatalError("WordPressAuthenticator is already initialized")
        }

        privateInstance = WordPressAuthenticator(configuration: configuration,
                                                 style: style,
                                                 unifiedStyle: unifiedStyle,
                                                 displayImages: displayImages,
                                                 displayStrings: displayStrings)
    }

    // MARK: - Public Methods
    
    public func supportPushNotificationReceived() {
        NotificationCenter.default.post(name: .wordpressSupportNotificationReceived, object: nil)
    }

    public func supportPushNotificationCleared() {
        NotificationCenter.default.post(name: .wordpressSupportNotificationCleared, object: nil)
    }
    
    /// Indicates if the specified ViewController belongs to the Authentication Flow, or not.
    ///
    public class func isAuthenticationViewController(_ viewController: UIViewController) ->  Bool {
        return viewController is LoginPrologueViewController || viewController is NUXViewControllerBase
    }

    /// Indicates if the received URL is a Google Authentication Callback.
    ///
    @objc public func isGoogleAuthUrl(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix(configuration.googleLoginScheme)
    }

    /// Indicates if the received URL is a WordPress.com Authentication Callback.
    ///
    @objc public func isWordPressAuthUrl(_ url: URL) -> Bool {
        let expectedPrefix = configuration.wpcomScheme + "://" + Constants.magicLinkUrlPath
        return url.absoluteString.hasPrefix(expectedPrefix)
    }

    /// Attempts to process the specified URL as a Google Authentication Link. Returns *true* on success.
    ///
    @objc public func handleGoogleAuthUrl(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    /// Attempts to process the specified URL as a WordPress Authentication Link. Returns *true* on success.
    ///
    @objc public func handleWordPressAuthUrl(_ url: URL, allowWordPressComAuth: Bool, rootViewController: UIViewController) -> Bool {
        return WordPressAuthenticator.openAuthenticationURL(url, allowWordPressComAuth: allowWordPressComAuth, fromRootViewController: rootViewController)
    }


    // MARK: - Helpers for presenting the login flow

    /// Used to present the new login flow from the app delegate
    @objc public class func showLoginFromPresenter(_ presenter: UIViewController, animated: Bool) {
        showLogin(from: presenter, animated: animated)
    }

    public class func showLogin(from presenter: UIViewController, animated: Bool, showCancel: Bool = false, restrictToWPCom: Bool = false) {
        defer {
            trackOpenedLogin()
        }

        let storyboard = Storyboard.login.instance
        if let controller = storyboard.instantiateInitialViewController() {
            if let childController = controller.children.first as? LoginPrologueViewController {
                childController.loginFields.restrictToWPCom = restrictToWPCom
                childController.showCancel = showCancel
            }
            controller.modalPresentationStyle = .fullScreen
            presenter.present(controller, animated: animated, completion: nil)
        }
    }

    /// Used to present the new wpcom-only login flow from the app delegate
    @objc public class func showLoginForJustWPCom(from presenter: UIViewController, xmlrpc: String? = nil, username: String? = nil, connectedEmail: String? = nil) {
        defer {
            trackOpenedLogin()
        }

        guard let controller = LoginEmailViewController.instantiate(from: .login) else {
            return
        }

        controller.loginFields.restrictToWPCom = true
        controller.loginFields.meta.jetpackBlogXMLRPC = xmlrpc
        controller.loginFields.meta.jetpackBlogUsername = username

        if let email = connectedEmail {
            controller.loginFields.username = email
        } else {
            controller.offerSignupOption = true
        }

        let navController = LoginNavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        presenter.present(navController, animated: true, completion: nil)
    }

    /// Used to present the new self-hosted login flow from BlogListViewController
    @objc public class func showLoginForSelfHostedSite(_ presenter: UIViewController) {
        defer {
            trackOpenedLogin()
        }

        let controller = signinForWPOrg()
        let navController = LoginNavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        presenter.present(navController, animated: true, completion: nil)
    }

    /// Returns an instance of LoginSiteAddressViewController: allows the user to log into a WordPress.org website.
    ///
    @objc public class func signinForWPOrg() -> UIViewController {
        guard let controller = LoginSiteAddressViewController.instantiate(from: .login) else {
            fatalError("unable to create wpcom password screen")
        }

        return controller
    }


    // Helper used by WPAuthTokenIssueSolver
    @objc
    public class func signinForWPCom(dotcomEmailAddress: String?, dotcomUsername: String?, onDismissed: ((_ cancelled: Bool) -> Void)? = nil) -> UIViewController {
        let loginFields = LoginFields()
        loginFields.emailAddress = dotcomEmailAddress ?? String()
        loginFields.username = dotcomUsername ?? String()

        guard let controller = LoginWPComViewController.instantiate(from: .login) else {
            fatalError("unable to create wpcom password screen")
        }

        controller.loginFields = loginFields
        controller.dismissBlock = onDismissed

        return NUXNavigationController(rootViewController: controller)
    }


    /// Returns an instance of LoginEmailViewController.
    /// This allows the host app to configure the controller's features.
    ///
    public class func signinForWPCom() -> LoginEmailViewController {
        guard let controller = LoginEmailViewController.instantiate(from: .login) else {
            fatalError()
        }

        return controller
    }

    /// Returns an instance of `LoginPrologueLoginMethodViewController`.
    /// This allows the host app to show a screen with available sign in methods.
    ///
    public class func signinMethods(from presenter: UIViewController, onDismiss: ((_ cancelled: Bool) -> Void)?) -> UIViewController {
        guard let vc = LoginPrologueLoginMethodViewController.instantiate(from: .login) else {
            fatalError("Unable to instantiate login methods view controller")
        }

        let coordinator = SignInMethodsCoordinator(presenter: presenter, onDismiss: onDismiss)

//        vc.transitioningDelegate = self

        // Continue with WordPress.com button action
        vc.emailTapped = { [weak presenter] in
            let toVC = signinForWPCom()
            presenter?.navigationController?.pushViewController(toVC, animated: true)
        }

        // Continue with Google button action
        vc.googleTapped = { [weak presenter] in
            guard let presenter = presenter else {
                return
            }
            if WordPressAuthenticator.shared.configuration.enableUnifiedGoogle {
                presenter.navigationController?.pushViewController(unifiedGoogleView(), animated: true)
            } else {
                GoogleAuthenticator.sharedInstance.loginDelegate = coordinator
                GoogleAuthenticator.sharedInstance.showFrom(viewController: presenter, loginFields: vc.loginFields, for: .login)
            }
        }

        // Site address text link button action
        vc.selfHostedTapped = { [weak presenter] in
            let toVC: UIViewController
            if WordPressAuthenticator.shared.configuration.enableUnifiedSiteAddress {
                toVC = unifiedSiteAddressView()
            } else {
                toVC = signinForWPOrg()
            }
            presenter?.navigationController?.pushViewController(toVC, animated: true)
        }

        // Sign In With Apple (SIWA) button action
        vc.appleTapped = { [weak vc] in
            guard let vc = vc else {
                return
            }

            AppleAuthenticator.sharedInstance.delegate = coordinator
            AppleAuthenticator.sharedInstance.showFrom(viewController: presenter)
        }

        vc.modalPresentationStyle = .custom
        return vc
    }

    // Shows the VC that handles both Google login & signup.
    private class func googleView() -> GoogleAuthViewController {
        guard let vc = GoogleAuthViewController.instantiate(from: .googleAuth) else {
            fatalError("Failed to navigate to GoogleAuthViewController from LoginPrologueVC")
        }
        return vc
    }

    // Shows the VC that handles both Google login & signup.
    private class func unifiedGoogleView() -> GoogleAuthViewController {
        guard let vc = GoogleAuthViewController.instantiate(from: .googleAuth) else {
            fatalError("Failed to navigate to GoogleAuthViewController from LoginPrologueVC")
        }
        return vc
    }

    /// Navigates to the unified site address login flow.
    ///
    private class func unifiedSiteAddressView() -> SiteAddressViewController {
        guard let vc = SiteAddressViewController.instantiate(from: .siteAddress) else {
            fatalError("Failed to navigate from LoginPrologueViewController to SiteAddressViewController")
        }
        return vc
    }

    private class func trackOpenedLogin() {
        WordPressAuthenticator.track(.openedLogin)
    }


    // MARK: - Authentication Link Helpers


    /// Present a signin view controller to handle an authentication link.
    ///
    /// - Parameters:
    ///     - url: The authentication URL
    ///     - allowWordPressComAuth: Indicates if WordPress.com Authentication Links should be handled, or not.
    ///     - rootViewController: The view controller to act as the presenter for the signin view controller.
    ///                           By convention this is the app's root vc.
    ///
    @objc public class func openAuthenticationURL(_ url: URL, allowWordPressComAuth: Bool, fromRootViewController rootViewController: UIViewController) -> Bool {
        guard let token = url.query?.dictionaryFromQueryString().string(forKey: "token") else {
            DDLogError("Signin Error: The authentication URL did not have the expected path.")
            return false
        }

        let loginFields = retrieveLoginInfoForTokenAuth()

        // The only time we should expect a magic link login when there is already a default wpcom account
        // is when a user is logging into Jetpack.
        if allowWordPressComAuth == false && loginFields.meta.jetpackLogin == false {
            DDLogInfo("App opened with authentication link but there is already an existing wpcom account.")
            return false
        }

        let storyboard = Storyboard.emailMagicLink.instance
        guard let loginController = storyboard.instantiateViewController(withIdentifier: "LinkAuthView") as? NUXLinkAuthViewController else {
            DDLogInfo("App opened with authentication link but couldn't create login screen.")
            return false
        }
        loginController.loginFields = loginFields
        loginController.token = token
        let controller = loginController

        if let linkSource = loginFields.meta.emailMagicLinkSource {
            switch linkSource {
            case .signup:
                WordPressAuthenticator.track(.signupMagicLinkOpened)
            case .login:
                WordPressAuthenticator.track(.loginMagicLinkOpened)
            }
        }

        let navController = LoginNavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen

        // The way the magic link flow works some view controller might
        // still be presented when the app is resumed by tapping on the auth link.
        // We need to do a little work to present the SigninLinkAuth controller
        // from the right place.
        // - If the rootViewController is not presenting another vc then just
        // present the auth controller.
        // - If the rootViewController is presenting another NUX vc, dismiss the
        // NUX vc then present the auth controller.
        // - If the rootViewController is presenting *any* other vc, present the
        // auth controller from the presented vc.
        let presenter = rootViewController.topmostPresentedViewController
        if presenter.isKind(of: NUXNavigationController.self) || presenter.isKind(of: LoginNavigationController.self),
            let parent = presenter.presentingViewController {
            parent.dismiss(animated: false, completion: {
                parent.present(navController, animated: false, completion: nil)
            })
        } else {
            presenter.present(navController, animated: false, completion: nil)
        }

        deleteLoginInfoForTokenAuth()
        return true
    }


    // MARK: - Site URL helper


    /// The base site URL path derived from `loginFields.siteUrl`
    ///
    /// - Parameter string: The source URL as a string.
    ///
    /// - Returns: The base URL or an empty string.
    ///
    class func baseSiteURL(string: String) -> String {
        guard let siteURL = NSURL(string: NSURL.idnEncodedURL(string)), string.count > 0 else {
            return ""
        }

        var path = siteURL.absoluteString!
        let isSiteURLSchemeEmpty = siteURL.scheme == nil || siteURL.scheme!.isEmpty

        if path.isWordPressComPath() {
            if isSiteURLSchemeEmpty {
                path = "https://\(path)"
            } else if path.range(of: "http://") != nil {
                path = path.replacingOccurrences(of: "http://", with: "https://")
            }
        } else if isSiteURLSchemeEmpty {
            path = "https://\(path)"
        }

        path.removeSuffix("/wp-login.php")
        try? path.removeSuffix(pattern: "/wp-admin/?")
        path.removeSuffix("/")

        return path
    }


    // MARK: - Helpers for Saved Magic Link Info

    /// Saves certain login information in NSUserDefaults
    ///
    /// - Parameter loginFields: The loginFields instance from which to save.
    ///
    class func storeLoginInfoForTokenAuth(_ loginFields: LoginFields) {
        var dict: [String: String] = [
            Constants.username: loginFields.username
        ]
        if let xmlrpc = loginFields.meta.jetpackBlogXMLRPC {
            dict[Constants.jetpackBlogXMLRPC] = xmlrpc
        }

        if let username = loginFields.meta.jetpackBlogUsername {
            dict[Constants.jetpackBlogUsername] = username
        }

        if let linkSource = loginFields.meta.emailMagicLinkSource {
            dict[Constants.emailMagicLinkSource] = String(linkSource.rawValue)
        }

        UserDefaults.standard.set(dict, forKey: Constants.authenticationInfoKey)
    }


    /// Retrieves stored login information if any.
    ///
    /// - Returns: A loginFields instance or nil.
    ///
    class func retrieveLoginInfoForTokenAuth() -> LoginFields {

        let loginFields = LoginFields()

        guard let dict = UserDefaults.standard.dictionary(forKey: Constants.authenticationInfoKey) else {
            return loginFields
        }

        if let username = dict[Constants.username] as? String {
            loginFields.username = username
        }

        if let linkSource = dict[Constants.emailMagicLinkSource] as? String,
            let linkSourceRawValue = Int(linkSource) {
            loginFields.meta.emailMagicLinkSource = EmailMagicLinkSource(rawValue: linkSourceRawValue)
        }

        if let xmlrpc = dict[Constants.jetpackBlogXMLRPC] as? String {
            loginFields.meta.jetpackBlogXMLRPC = xmlrpc
        }

        if let username = dict[Constants.jetpackBlogUsername] as? String {
            loginFields.meta.jetpackBlogUsername = username
        }

        return loginFields
    }


    /// Removes stored login information from NSUserDefaults
    ///
    class func deleteLoginInfoForTokenAuth() {
        UserDefaults.standard.removeObject(forKey: Constants.authenticationInfoKey)
    }


    // MARK: - Other Helpers


    /// Opens Safari to display the forgot password page for a wpcom or self-hosted
    /// based on the passed LoginFields instance.
    ///
    /// - Parameter loginFields: A LoginFields instance.
    ///
    class func openForgotPasswordURL(_ loginFields: LoginFields) {
        let baseURL = loginFields.meta.userIsDotCom ? "https://wordpress.com" : WordPressAuthenticator.baseSiteURL(string: loginFields.siteAddress)
        let forgotPasswordURL = URL(string: baseURL + "/wp-login.php?action=lostpassword&redirect_to=wordpress%3A%2F%2F")!
        UIApplication.shared.open(forgotPasswordURL)
    }

    /// Returns the WordPressAuthenticator Bundle
    /// If installed via CocoaPods, this will be WordPressAuthenticator.bundle,
    /// otherwise it will be the framework bundle.
    ///
    public class var bundle: Bundle {
        let defaultBundle = Bundle(for: WordPressAuthenticator.self)
        // If installed with CocoaPods, resources will be in WordPressAuthenticator.bundle
        if let bundleURL = defaultBundle.resourceURL,
            let resourceBundle = Bundle(url: bundleURL.appendingPathComponent("WordPressAuthenticatorResources.bundle")) {
            return resourceBundle
        }
        // Otherwise, the default bundle is used for resources
        return defaultBundle
    }

    // MARK: - 1Password Helper


    /// Request credentails from 1Password (if supported)
    ///
    /// - Parameter sender: A UIView. Typically the button the user tapped on.
    ///
    class func fetchOnePasswordCredentials(_ controller: UIViewController, sourceView: UIView, loginFields: LoginFields, success: @escaping ((_ loginFields: LoginFields) -> Void)) {

        let loginURL = loginFields.meta.userIsDotCom ? OnePasswordDefaults.dotcomURL : loginFields.siteAddress

        OnePasswordFacade().findLogin(for: loginURL, viewController: controller, sender: sourceView, success: { (username, password, otp) in
            loginFields.username = username
            loginFields.password = password
            loginFields.multifactorCode = otp ?? String()

            WordPressAuthenticator.track(.onePasswordLogin)
            success(loginFields)

        }, failure: { error in
            guard error != .cancelledByUser else {
                return
            }

            DDLogError("OnePassword Error: \(error.localizedDescription)")
            WordPressAuthenticator.track(.onePasswordFailed)
        })
    }
}

@available(iOS 13.0, *)
public extension WordPressAuthenticator {

    func getAppleIDCredentialState(for userID: String, completion:  @escaping (ASAuthorizationAppleIDProvider.CredentialState, Error?) -> Void) {
        AppleAuthenticator.sharedInstance.getAppleIDCredentialState(for: userID) { (state, error) in
            // If credentialState == .notFound, error will have a value.
            completion(state, error)
        }
    }

    func startObservingAppleIDCredentialRevoked(completion:  @escaping () -> Void) {
        appleIDCredentialObserver = NotificationCenter.default.addObserver(forName: AppleAuthenticator.credentialRevokedNotification, object: nil, queue: nil) { (notification) in
            completion()
        }
    }
    
    func stopObservingAppleIDCredentialRevoked() {
        if let observer = appleIDCredentialObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        appleIDCredentialObserver = nil
    }

}
