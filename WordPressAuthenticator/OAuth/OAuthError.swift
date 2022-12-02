enum OAuthError {

    struct InconsistentASWebAuthenticationSessionCompletion: LocalizedError {
        let errorDescription = "ASWebAuthenticationSession authentication finished with neither a callback URL nor error"
    }

    struct FailedToBuildURLQuery: LocalizedError {
        let requestBody: OAuthTokenRequestBody

        lazy var errorDescription = "Failed to build URL query string from \(requestBody)"
    }

    struct FailedToEncodeURLQuery: LocalizedError {
        let query: String

        lazy var errorDescription = "Failed to encode URL query string '\(query)'"
    }
}
