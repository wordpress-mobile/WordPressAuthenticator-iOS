import UIKit
import WebKit
import WordPressAuthenticator

class ViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
    let reuseIdentifier = "cell"

    struct CellConfiguration {
        let text: String
        let action: () -> Void
    }

    lazy var configuration: [CellConfiguration] = [
        CellConfiguration(text: "Show Login") { [weak self] in
            guard let self else { fatalError() }
            WordPressAuthenticator.showLoginFromPresenter(self, animated: true)
        }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Authenticator Demo 🔐"

        setUpTableView()

        // In a proper app, we'd want to split this call to keep the code readable. Here, it's
        // useful to keep it all in one block to show how insanely long it is.
        WordPressAuthenticator.initialize(
            configuration: WordPressAuthenticatorConfiguration(
                wpcomClientId: ApiCredentials.client,
                wpcomSecret: ApiCredentials.secret,
                wpcomScheme: "wordpress-authenticator-ios-demo",
                wpcomTermsOfServiceURL: "https://wordpress.com/tos/",
                wpcomBaseURL: "https://wordpress.com",
                wpcomAPIBaseURL: "https://public-api.wordpress.com/",
                googleLoginClientId: ApiCredentials.googleLoginClientId,
                googleLoginServerClientId: ApiCredentials.googleLoginServerClientId,
                googleLoginScheme: ApiCredentials.googleLoginSchemeId,
                userAgent: "\(WKWebView.userAgent)-wordpress-authenticator-demo-app",
                showLoginOptions: true,
                enableSignUp: true,
                // SIWA might require additional settings in the Developer Portal... Keeping it off
                // for the moment
                enableSignInWithApple: false,
                enableSignupWithGoogle: true,
                enableUnifiedAuth: true,
                enableUnifiedCarousel: true
            ),
            style: WordPressAuthenticatorStyle(
                primaryNormalBackgroundColor: .red,
                primaryNormalBorderColor: .none,
                primaryHighlightBackgroundColor: .red,
                primaryHighlightBorderColor: .none,
                secondaryNormalBackgroundColor: .red,
                secondaryNormalBorderColor: .red,
                secondaryHighlightBackgroundColor: .red,
                secondaryHighlightBorderColor: .red,
                disabledBackgroundColor: .red,
                disabledBorderColor: .red,
                primaryTitleColor: .white,
                secondaryTitleColor: .label,
                disabledTitleColor: .red,
                disabledButtonActivityIndicatorColor: .label,
                textButtonColor: .red,
                textButtonHighlightColor: .red,
                instructionColor: .label,
                subheadlineColor: .secondaryLabel,
                placeholderColor: .red,
                viewControllerBackgroundColor: .red,
                textFieldBackgroundColor: .red,
                navBarImage: UIImage(),
                navBarBadgeColor: .red,
                navBarBackgroundColor: .red
            ),
            unifiedStyle: WordPressAuthenticatorUnifiedStyle(
                borderColor: .separator,
                errorColor: .red,
                textColor: .label,
                textSubtleColor: .red,
                textButtonColor: .red,
                textButtonHighlightColor: .red,
                viewControllerBackgroundColor: .red,
                navBarBackgroundColor: .red,
                navButtonTextColor: .red,
                navTitleTextColor: .red
            )
        )

        WordPressAuthenticator.shared.delegate = self
    }

    func setUpTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [NSLayoutConstraint.Attribute](arrayLiteral: .top, .right, .bottom, .left)
            .map {
                NSLayoutConstraint(
                    item: tableView,
                    attribute: $0,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: $0,
                    multiplier: 1,
                    constant: 0
                )
            }
        view.addConstraints(constraints)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        configuration.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        guard let configurationItem = configuration(for: indexPath) else { return cell }

        var content = cell.defaultContentConfiguration()
        content.text = configurationItem.text
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let configurationItem = configuration(for: indexPath) else { return }
        configurationItem.action()
    }
}

extension ViewController {

    func configuration(for indexPath: IndexPath) -> CellConfiguration? {
        guard configuration.count > indexPath.row else { return .none }
        return configuration[indexPath.row]
    }
}

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
        printFunctionName()
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
