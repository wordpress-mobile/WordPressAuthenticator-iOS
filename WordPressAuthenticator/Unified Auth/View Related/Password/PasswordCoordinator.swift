/// Coordinates the navigation after entering WP.com username.
/// Based on the configuration, it could automatically send a magic link and proceed the magic link requested screen on success and fall back to password.
@MainActor
final class PasswordCoordinator {
    private let navigationController: UINavigationController
    private let source: SignInSource?
    private let loginFields: LoginFields
    private let tracker: AuthenticatorAnalyticsTracker
    private let configuration: WordPressAuthenticatorConfiguration

    init(navigationController: UINavigationController,
         source: SignInSource?,
         loginFields: LoginFields,
         tracker: AuthenticatorAnalyticsTracker,
         configuration: WordPressAuthenticatorConfiguration) {
        self.navigationController = navigationController
        self.source = source
        self.loginFields = loginFields
        self.tracker = tracker
        self.configuration = configuration
    }

    func start() async {
        if configuration.isWPComMagicLinkPreferredToPassword {
            tracker.track(click: .requestMagicLink)
            let result = await requestMagicLink()
            switch result {
            case .success:
                loginFields.restrictToWPCom = true
                showMagicLinkRequested()
            case .failure(let error):
                // When magic link request fails, falls back to the password flow.
                showPassword()
                tracker.track(failure: error.localizedDescription)
            }
        } else {
            showPassword()
        }
    }
}

private extension PasswordCoordinator {
    enum MagicLinkRequestError: Error {
        case invalidEmail
    }

    /// Makes the call to request a magic authentication link be emailed to the user.
    func requestMagicLink() async -> Result<Void, Error> {
        await withCheckedContinuation { continuation in
            loginFields.meta.emailMagicLinkSource = .login

            let email = loginFields.username
            guard email.isValidEmail() else {
                return continuation.resume(returning: .failure(MagicLinkRequestError.invalidEmail))
            }


            let service = WordPressComAccountService()
            service.requestAuthenticationLink(for: email,
                                              jetpackLogin: loginFields.meta.jetpackLogin,
                                              success: {
                continuation.resume(returning: .success(()))
            }, failure: { error in
                continuation.resume(returning: .failure(error))
            })
        }
    }

    /// After a magic link is successfully sent, navigates the user to the requested screen.
    func showMagicLinkRequested() {
        let vc = MagicLinkRequestedViewController(email: loginFields.username) { [weak self] in
            self?.showPassword()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    /// Navigates the user to enter WP.com password.
    func showPassword() {
        guard let vc = PasswordViewController.instantiate(from: .password) else {
            return DDLogError("Failed to navigate to PasswordViewController from GetStartedViewController")
        }

        vc.source = source
        vc.loginFields = loginFields
        vc.trackAsPasswordChallenge = false

        navigationController.pushViewController(vc, animated: true)
    }
}
