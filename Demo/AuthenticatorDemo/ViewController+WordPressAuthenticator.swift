import WebKit
import WordPressAuthenticator
import WordPressKit

extension ViewController {

    func initializeWordPressAuthenticator() {
        // In a proper app, we'd want to split this call to keep the code readable. Here, it's
        // useful to keep it all in one block to show how insanely long it is.
        WordPressAuthenticator.initialize(
            configuration: WordPressAuthenticatorConfiguration(
                wpcomClientId: APICredentials.client,
                wpcomSecret: APICredentials.secret,
                wpcomScheme: "wordpress-authenticator-ios-demo",
                wpcomTermsOfServiceURL: "https://wordpress.com/tos/",
                wpcomBaseURL: "https://wordpress.com",
                wpcomAPIBaseURL: "https://public-api.wordpress.com/",
                googleLoginClientId: APICredentials.googleLoginClientId,
                googleLoginServerClientId: APICredentials.googleLoginServerClientId,
                googleLoginScheme: APICredentials.googleLoginSchemeId,
                userAgent: "\(WKWebView.userAgent)-wordpress-authenticator-demo-app",
                showLoginOptions: true,
                enableSignUp: true,
                // SIWA might require additional settings in the Developer Portal... Keeping it off
                // for the moment
                enableSignInWithApple: false,
                enableSignupWithGoogle: true,
                enableUnifiedAuth: true,
                enableUnifiedCarousel: true,
                // Notice that this is required as well as `enableSignupWithGoogle` to show the
                // option to login with Google.
                enableSocialLogin: true
            ),
            style: WordPressAuthenticatorStyle(
                // Primary (normal and highlight) is the color of buttons such as "Log in or signup
                // with WordPress.com"
                primaryNormalBackgroundColor: .orange,
                primaryNormalBorderColor: .none,
                primaryHighlightBackgroundColor: .brown,
                primaryHighlightBorderColor: .none,
                // Secondary (normal and highlight) is the color of buttons such as "Enter your
                // existing site address" (the one just below "Log in or signup...") or "Continue
                // with Google".
                secondaryNormalBackgroundColor: .blue,
                secondaryNormalBorderColor: .black,
                secondaryHighlightBackgroundColor: .purple,
                secondaryHighlightBorderColor: .black,
                disabledBackgroundColor: .systemGray,
                disabledBorderColor: .systemGray,
                primaryTitleColor: .white,
                secondaryTitleColor: .white,
                disabledTitleColor: .white,
                disabledButtonActivityIndicatorColor: .label,
                textButtonColor: .red,
                textButtonHighlightColor: .red,
                instructionColor: .label,
                subheadlineColor: .secondaryLabel,
                placeholderColor: .red,
                viewControllerBackgroundColor: .red,
                textFieldBackgroundColor: .red,
                // The navBar settings here are ignored. Those in
                // `WordPressAuthenticatorUnifiedStyle` take precedence.
                navBarImage: UIImage(),
                navBarBadgeColor: .red,
                navBarBackgroundColor: .orange
            ),
            unifiedStyle: WordPressAuthenticatorUnifiedStyle(
                borderColor: .separator,
                errorColor: .red,
                textColor: .label,
                textSubtleColor: .blue,
                textButtonColor: .purple,
                textButtonHighlightColor: .orange,
                viewControllerBackgroundColor: .systemBackground,
                navBarBackgroundColor: .blue,
                navButtonTextColor: .white,
                navTitleTextColor: .white
            )
        )
    }

    // TODO: Need to handle new user flow
    func newGoogleSignInFlow() {
        Task.init {
            do {
                let token = try await self.googleAuthenticator.getOAuthToken()

                presentAlert(
                    title: "🎉",
                    message: "Successfully authenticated with Google.\n\nEmail in received token: \(token.email ?? "none")",
                    onDismiss: {}
                )
            } catch {
                presentAlert(title: "❌", message: error.localizedDescription, onDismiss: {})
            }
        }
    }
}
