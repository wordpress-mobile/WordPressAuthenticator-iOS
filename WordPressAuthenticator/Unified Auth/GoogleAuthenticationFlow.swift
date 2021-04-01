import Combine
import AuthenticationServices

struct GoogleAuthenticationCredentials {
    let clientID: String
    let redirectURI: String
}

struct GoogleAuthenticationFlow {

    class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            ASPresentationAnchor()
        }
    }

    private let credentials: GoogleAuthenticationCredentials

    private let contextProvider = PresentationContextProvider()

    init(credentials: GoogleAuthenticationCredentials) {
        self.credentials = credentials
    }

    func signIn() {
        fetchAuthorizationCode().map {
            // TODO: Go grab the token pair
        }
    }

    private func fetchAuthorizationCode() -> Future<URL, Error> {

        return Future<URL, Error> { completion in
            let url = googleAuthorizationUrl(withClientID: credentials.clientID, redirectURI: credentials.redirectURI)
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: credentials.redirectURI) { (url, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                } else {
                    fatalError("This shouldn't be possible (but we should emit an 'unknown login error' instead of crashing")
                }
            }

            session.presentationContextProvider = contextProvider

            session.start()
        }
    }
}

// MARK: URL Creation
extension GoogleAuthenticationFlow {
    

    // TODO: Add token Url
    func googleAuthorizationUrl(withClientID clientID: String, redirectURI: String) -> URL {
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI + ":/code"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid profile email"),
            URLQueryItem(name: "code_challenge", value: UUID().uuidString),
            URLQueryItem(name: "code_challenge_method", value: "plain")
        ]

        return try! components.asURL()
    }

    static func googleLoginUrl(withClientID clientID: String, clientSecret: String, redirectURI: String) -> URL {
        var baseURL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        return try! components.asURL()
    }

}
