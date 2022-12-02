import Foundation

// It's acceptable to force-unwrap here because, for this call to fail we'd need a developer error,
// which we would catch because the unit tests would crash.
extension URL {

    static var googleSignInBaseURL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!

    static var googleSignInOAuthTokenURL = URL(string: "https://oauth2.googleapis.com/token")!
}

extension URL {

    // TODO: This is incomplete
    static func googleSignInAuthURL(clientId: GoogleClientId, pkce: ProofKeyForCodeExchange) throws -> URL {
        let queryItems = [
            ("client_id", clientId.value),
            ("code_challenge", pkce.codeCallenge),
            ("code_challenge_method", pkce.mode.method),
            ("redirect_uri", clientId.defaultRedirectURI),
            ("response_type", "code"),
            // TODO: We might want to add some of these or them configurable
            //
            // The request we make with the SDK asks for:
            //
            // - email
            // - profile
            // - https://www.googleapis.com/auth/userinfo.email
            // - https://www.googleapis.com/auth/userinfo.profile
            // - openid
            //
            // See https://developers.google.com/identity/protocols/oauth2/scopes
            ("scope", "https://www.googleapis.com/auth/userinfo.email")
        ].map { URLQueryItem(name: $0.0, value: $0.1) }

        if #available(iOS 16.0, *) {
            return googleSignInBaseURL.appending(queryItems: queryItems)
        } else {
            let baseURL = googleSignInBaseURL
            guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
                throw URLError(
                    .unsupportedURL,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Could not create `URLComponents` instance from \(baseURL)"
                    ]
                )
            }

            components.queryItems = queryItems
            return try components.asURL()
        }
    }
}
