/// Models the request to send for an OAuth token
///
/// - Note: See documentation at https://developers.google.com/identity/protocols/oauth2/native-app#exchange-authorization-code
struct OAuthTokenRequestBody: Encodable {
    let clientId: String
    let clientSecret: String
    let code: String
    let codeVerifier: String
    let grantType: String
    let redirectURI: String

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code
        case codeVerifier = "code_verifier"
        case grantType = "grant_type"
        case redirectURI = "redirect_uri"
    }

    func asURLEncodedData() throws -> Data {
        let params = [
            (CodingKeys.clientId.rawValue, clientId),
            (CodingKeys.clientSecret.rawValue, clientSecret),
            (CodingKeys.code.rawValue, code),
            (CodingKeys.codeVerifier.rawValue, codeVerifier),
            (CodingKeys.grantType.rawValue, grantType),
            (CodingKeys.redirectURI.rawValue, redirectURI),
        ]

        let items = params.map { URLQueryItem(name: $0.0, value: $0.1) }

        var components = URLComponents()
        components.queryItems = items

        // We can assume `query` to never be nil because we set `queryItems` in the line above.
        return Data(components.query!.utf8)
    }
}