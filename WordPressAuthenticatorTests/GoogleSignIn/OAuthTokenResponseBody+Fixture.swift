@testable import WordPressAuthenticator

extension OAuthTokenResponseBody {

    static func fixture(rawIDToken: String? = validJWTString) -> Self {
        OAuthTokenResponseBody(
            accessToken: "access_token",
            expiresIn: 1,
            rawIDToken: rawIDToken,
            refreshToken: .none,
            scope: "s",
            tokenType: "t"
        )
    }
}
