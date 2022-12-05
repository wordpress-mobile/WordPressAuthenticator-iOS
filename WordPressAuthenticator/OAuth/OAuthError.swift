enum OAuthError: LocalizedError {

    // ASWebAuthenticationSession
    case inconsistentWebAuthenticationSessionCompletion

    // OAuth token response
    case urlDidNotContainCodeParameter(url: URL)

    var errorDescription: String {
        switch self {
        case .inconsistentWebAuthenticationSessionCompletion:
            return "ASWebAuthenticationSession authentication finished with neither a callback URL nor error"
        case .urlDidNotContainCodeParameter(let url):
            return "Could not find 'code' parameter in URL '\(url)'"
        }
    }
}
