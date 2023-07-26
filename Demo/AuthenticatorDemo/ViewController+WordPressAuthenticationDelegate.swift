import WebKit
import WordPressAuthenticator
import WordPressKit

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

    func presentSignupEpilogue(in navigationController: UINavigationController, for credentials: AuthenticatorCredentials, socialService: SocialServiceName?) {
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
            self?.sync(credentials: credentials)
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

extension ViewController {

    // This is just so we can avoid nesting within a dismiss block and the weak self dance.
    //
    // See WordPress iOS
    //
    // - WordPressAuthenticationManager sync(credentials:, onCompletion:)
    // - WordPressAuthenticationManager syncWPCom(authToken:, isJetpackLogin:, onCompletion:)
    // - AccountService createOrUpdateAccountWithAuthToken:success:failure:
    private func sync(credentials: AuthenticatorCredentials) {
        switch (credentials.wpcom, credentials.wporg) {
        case (.none, .none), (.some, .some):
            fatalError("Inconsistent state!")
        case (.none, .some):
            fatalError("Not implemented yet")
        case (.some(let wpComCredentials), .none):
            let api = WordPressComRestApi(
                oAuthToken: wpComCredentials.authToken,
                // TODO: there should be a way to read the user agent from the library configs
                userAgent: WKWebView.userAgent
            )
            let remote = AccountServiceRemoteREST(wordPressComRestApi: api)

            remote.getAccountDetails(
                success: { [weak self] remoteUser in
                    guard let remoteUser else {
                        fatalError("Received no RemoteUser – Likely an Objective-C types byproduct.")
                    }

                    self?.presentAlert(
                        title: "🎉",
                        message: "Welcome \(remoteUser.displayName ?? "'no display name'")",
                        onDismiss: {}
                    )
                },
                failure: { error in
                    print(error!.localizedDescription)
                }
            )
        }
    }
}
