enum OAuthError {

    enum ASWebAuthenticationSession {

        struct InconsistentSessionCompletion: LocalizedError {
            let errorDescription = "ASWebAuthenticationSession authentication finished with neither a callback URL nor error"
        }
    }

    enum TokenRequestBody {

        struct FailedToBuildURLQuery: LocalizedError {
            let requestBody: OAuthTokenRequestBody

            lazy var errorDescription = "Failed to build URL query string from \(requestBody)"
        }

        struct FailedToEncodeURLQuery: LocalizedError {
            let query: String

            lazy var errorDescription = "Failed to encode URL query string '\(query)'"
        }
    }

    enum TokenResponse {

        struct URLDidNotContainCodeParameter: LocalizedError {

            let url: URL

            lazy var errorDescription = "Could not find 'code' parameter in URL '\(url)"
        }
    }
}
