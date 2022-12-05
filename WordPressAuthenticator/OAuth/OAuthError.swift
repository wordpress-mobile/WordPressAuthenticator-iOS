enum OAuthError: LocalizedError {

    case inconsistentWebAuthenticationSessionCompletion

    case failedToBuildURLQuery

    case failedToEncodeURLQuery(query: String)

    case tokenURLDidNotContainCodeParameter(url: URL)

    var errorDescription: String {
        switch self {
        case .failedToBuildURLQuery:
            return "Failed to build URL query string"
        case .failedToEncodeURLQuery(let query):
            return "Failed to encode URL query string '\(query)'"
        case .inconsistentWebAuthenticationSessionCompletion:
            return "ASWebAuthenticationSession authentication finished with neither a callback URL nor error"
        case .tokenURLDidNotContainCodeParameter(let url):
            return "Could not find 'code' parameter in URL '\(url)"
        }
    }
}
