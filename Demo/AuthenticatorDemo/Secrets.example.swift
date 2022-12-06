enum APICredentials {

    // WordPress.com OAuth ClientID / Client Secret
    static let client = "0"
    static let secret = ""

    // Google Login
    static let googleLoginClientId = ""
    static let googleLoginSchemeId = ""
    static let googleLoginServerClientId = ""
}

// In a proper app, we'd split production secrets from test secrets in two
// files and include each only in the appropriate target(s).
//
// Given this is a demo app, we can be a bit less clean in the interest of
// simplicity and use a single file to include in both application and test
// targets.
extension APICredentials {

    enum Tests {

        enum GoogleAccount {
            static let email = ""
            static let password = ""
        }
    }
}
