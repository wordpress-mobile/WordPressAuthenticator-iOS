import AuthenticationServices

extension ASWebAuthenticationSession {

    /// Wrapper around the default `init(url:, callbackULRScheme:, completionHandler:)` where the
    /// `completionHandler` argument is a `Result<URL, Error>` instead of a `URL` and `Error` pair.
    convenience init(url: URL, callbackURLScheme: String, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        self.init(url: url, callbackURLScheme: callbackURLScheme) { callbackURL, error in
            switch (callbackURL, error) {
            case (.none, .some(let error)):
                completionHandler(.failure(error))
            case (.none, .none):
                let error = NSError(
                    domain: "org.wordpress.authenticator",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "ASWebAuthenticationSession authentication finished with neither a callback URL nor error"
                    ]
                )
                completionHandler(.failure(error))
            case (.some(let url), .none):
                completionHandler(.success(url))
            case (.some, .some(let error)):
                // TODO: Is it okay to be conservative and prioritize errors over successes?
                completionHandler(.failure(error))
            }
        }
    }
}
