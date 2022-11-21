import WordPressAuthenticator

extension ViewController: WordPressAuthenticatorDelegate {

    var dismissActionEnabled: Bool { true }

    var supportActionEnabled: Bool { true }

    var wpcomTermsOfServiceEnabled: Bool { true }

    var showSupportNotificationIndicator: Bool { true }

    var supportEnabled: Bool { true }

    var allowWPComLogin: Bool { true }

    func createdWordPressComAccount(username: String, authToken: String) {
        print(username)
        print(authToken)
    }

    func userAuthenticatedWithAppleUserID(_ appleUserID: String) {
        print(appleUserID)
    }

    func presentSupportRequest(from sourceViewController: UIViewController, sourceTag: WordPressSupportSourceTag) {
        fatalError("TODO")
    }

    func shouldPresentUsernamePasswordController(for siteInfo: WordPressComSiteInfo?, onCompletion: @escaping (WordPressAuthenticatorResult) -> Void) {
        fatalError("TODO")
    }

    func presentLoginEpilogue(in navigationController: UINavigationController, for credentials: AuthenticatorCredentials, source: SignInSource?, onDismiss: @escaping () -> Void) {
        fatalError("TODO")
    }

    func presentSignupEpilogue(in navigationController: UINavigationController, for credentials: AuthenticatorCredentials, service: SocialService?) {
        fatalError("TODO")
    }

    func presentSupport(from sourceViewController: UIViewController, sourceTag: WordPressSupportSourceTag, lastStep: AuthenticatorAnalyticsTracker.Step, lastFlow: AuthenticatorAnalyticsTracker.Flow) {
        fatalError("TODO")
    }

    func shouldPresentLoginEpilogue(isJetpackLogin: Bool) -> Bool {
        true
    }

    func shouldHandleError(_ error: Error) -> Bool {
        print(error)
        return true
    }

    func handleError(_ error: Error, onCompletion: @escaping (UIViewController) -> Void) {
        dismiss(animated: true) { [weak self] in
            self?.presentAlert(
                title: "Authentication Error",
                message: "\(error.localizedDescription)",
                onDismiss: {}
            )
        }
    }

    func shouldPresentSignupEpilogue() -> Bool {
        true
    }

    func sync(credentials: AuthenticatorCredentials, onCompletion: @escaping () -> Void) {
        dismiss(animated: true) { [weak self] in
            self?.presentAlert(
                title: "Authentication Successful",
                message: "Next step will be syncing credentials",
                onDismiss: {}
            )
        }
    }

    func track(event: WPAnalyticsStat) {
        print(event)
    }

    func track(event: WPAnalyticsStat, properties: [AnyHashable: Any]) {
        print(event)
        print(properties)
    }

    func track(event: WPAnalyticsStat, error: Error) {
        print(event)
        print(error)
    }
}
