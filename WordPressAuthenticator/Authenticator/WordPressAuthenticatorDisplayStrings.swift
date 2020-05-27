import Foundation


// MARK: - WordPress Authenticator Display Strings
//
public struct WordPressAuthenticatorDisplayStrings {
    /// Strings for the large title on the page.
    ///
    public var siteAddressTitle: String

    /// Strings: Login instructions.
    ///
    public let emailLoginInstructions: String

    public let jetpackLoginInstructions: String

    public let siteLoginInstructions: String

    /// Designated initializer.
    ///
    public init(siteAddressTitle: String = "",
                emailLoginInstructions: String,
                jetpackLoginInstructions: String,
                siteLoginInstructions: String) {
        self.siteAddressTitle = siteAddressTitle
        self.emailLoginInstructions = emailLoginInstructions
        self.jetpackLoginInstructions = jetpackLoginInstructions
        self.siteLoginInstructions = siteLoginInstructions
    }
}

public extension WordPressAuthenticatorDisplayStrings {
    static var defaultStrings: WordPressAuthenticatorDisplayStrings {
        return WordPressAuthenticatorDisplayStrings(
            siteAddressTitle: NSLocalizedString("Log In",
                                                comment: "Large title on the screen that tells the user where they are."),
            emailLoginInstructions: NSLocalizedString("Log in to your WordPress.com account with your email address.",
                                                      comment: "Instruction text on the login's email address screen."),
            jetpackLoginInstructions: NSLocalizedString("Log in to the WordPress.com account you used to connect Jetpack.",
                                                        comment: "Instruction text on the login's email address screen."),
            siteLoginInstructions: NSLocalizedString("Enter the address of the WordPress site you'd like to connect.",
                                                     comment: "Instruction text on the login's site addresss screen.")
        )
    }
}
