import UIKit
import WebKit
import WordPressAuthenticator

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    override func viewDidAppear(_ animated: Bool) {
        WordPressAuthenticator.showLoginFromPresenter(self, animated: true)
    }
}
