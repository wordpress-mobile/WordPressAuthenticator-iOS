import Foundation

// It's acceptable to force-unwrap here because, for this call to fail we'd need a developer error,
// which we would catch because the unit tests would crash.
extension URL {

    static var googleSignInBaseURL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!

    static var googleSignInOAuthTokenURL = URL(string: "https://oauth2.googleapis.com/token")!
}

extension URL {

    static func googleSignInAuthURL(clientId: GoogleClientId, pkce: ProofKeyForCodeExchange) throws -> URL {
        let queryItems = [
            ("client_id", clientId.value),
            ("code_challenge", pkce.codeCallenge),
            ("code_challenge_method", pkce.method.urlQueryParameterValue),
            ("redirect_uri", clientId.defaultRedirectURI),
            ("response_type", "code"),
            // TODO: We might want to add some of these or them configurable
            // See https://developers.google.com/identity/protocols/oauth2/scopes
            ("scope", "openid https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile")
        ].map { URLQueryItem(name: $0.0, value: $0.1) }

        if #available(iOS 16.0, *) {
            return googleSignInBaseURL.appending(queryItems: queryItems)
        } else {
            // Given `googleSignInBaseURL` is assumed as a valid URL, a `URLComponents` instance
            // should always be available.
            var components = URLComponents(url: googleSignInBaseURL, resolvingAgainstBaseURL: false)!
            components.queryItems = queryItems
            // Likewise, we can as long as the given `queryItems` are valid, we can assume `url` to
            // not be nil. If `queryItems` are invalid, a developer error has been committed, and
            // crashing is appropriate.
            return components.url!
        }
    }
}
