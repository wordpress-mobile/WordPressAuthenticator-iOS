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

    func newGoogleSignInFlow() {
        Task.init {
            do {
                let token = try await self.googleAuthenticator.authenticate()

                let wpComOAuthClient = WordPressComOAuthClientFacade(
                    client: APICredentials.client,
                    secret: APICredentials.secret
                )

                wpComOAuthClient?.authenticate(
                    withSocialIDToken: token,
                    service: SocialServiceName.google.rawValue,
                    success: { [weak self] string in
                        self?.presentAlert(
                            title: "🎉",
                            message: "Suceeded with '\(string ?? "no value")'", onDismiss: {}
                        )
                    },
                    needsMultiFactor: { intValue, optionalSocialLogin2FANonce in
                        print("needs multifactor")
                    },
                    existingUserNeedsConnection: { string in
                        if let string {
                            print("Got a string '\(string)'")
                        } else {
                            print("Succeeded, but with no string")
                        }
                    },
                    failure: { [weak self] error in
                        if let error {
                            self?.presentAlert(title: "❌", message: error.localizedDescription, onDismiss: {})
                        } else {
                            self?.presentAlert(
                                title: "❌",
                                message: "Failed in WordPressComOAuthClientFacade with no error",
                                onDismiss: {}
                            )
                        }
                    }
                )
            } catch {
                presentAlert(title: "❌", message: error.localizedDescription, onDismiss: {})
            }
        }
    }
}
