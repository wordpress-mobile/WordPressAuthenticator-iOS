import AuthenticationServices
import WebKit
import WordPressAuthenticator

extension ViewController {

    func initializeWordPressAuthenticator() {
        // In a proper app, we'd want to split this call to keep the code readable. Here, it's
        // useful to keep it all in one block to show how insanely long it is.
        WordPressAuthenticator.initialize(
            configuration: WordPressAuthenticatorConfiguration(
                wpcomClientId: APICredentials.client,
                wpcomSecret: APICredentials.secret,
                wpcomScheme: "wordpress-authenticator-ios-demo",
                wpcomTermsOfServiceURL: URL(string: "https://wordpress.com/tos/")!,
                wpcomBaseURL: URL(string: "https://wordpress.com")!,
                wpcomAPIBaseURL: URL(string: "https://public-api.wordpress.com/")!,
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

        WordPressAuthenticator.shared.delegate = self
    }

    // Note that this method does not try to authenticate the user with the WordPress backend.
    // It only verifies that we can get a token from Google.
    func getAuthTokenFromGoogle() {
        Task { @MainActor in
            do {
                let token = try await self.googleAuthenticator.getOAuthToken(from: self)

                presentAlert(
                    title: "🎉",
                    message: "Successfully authenticated with Google.\n\nEmail in received token: \(token.email)\n\nName: \(token.name)",
                    onDismiss: {}
                )
            } catch let error as OAuthError {
                presentAlert(title: "❌", message: error.errorDescription, onDismiss: {})
            } catch let error as ASWebAuthenticationSessionError
                where error.code == ASWebAuthenticationSessionError.canceledLogin {
                // In a production app, the UX would be better if we didn't present an alert.
                // But here, it's useful to show it to make the error handling visible for reference.
                presentAlert(title: "", message: "User cancelled", onDismiss: {})
            } catch {
                fatalError("Caught an error that was not of the expected `OAuthError` type: \(error)")
            }
        }
    }
}
