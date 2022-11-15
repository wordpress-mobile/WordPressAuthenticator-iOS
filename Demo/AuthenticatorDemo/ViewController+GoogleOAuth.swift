// Documentation links:
//
// - https://developer.apple.com/documentation/authenticationservices/authenticating_a_user_through_a_web_service
// - https://developers.google.com/identity/protocols/oauth2/native-app
// - https://developers.google.com/oauthplayground

import AuthenticationServices
import AppAuth

extension ViewController {

    func startGoogleOAuthFlow() {
        // See https://developers.google.com/identity/protocols/oauth2/web-server#creatingclient
        //
        // The guide at
        // https://www.oauth.com/oauth2-servers/signing-in-with-google/setting-up-the-environment/
        // uses a different URL:
        // https://www.googleapis.com/oauth2/v4/token – What's the difference?
        let googleAuthBaseURL = "https://accounts.google.com/o/oauth2/v2/auth"
        let queryItems: [URLQueryItem] = [
            .init(name: "client_id", value: ApiCredentials.googleLoginClientId),
            .init(name: "redirect_uri", value: googleAuthRedirectURL(from: ApiCredentials.googleLoginClientId)),
            .init(name: "response_type", value: "code"),
            // See https://developers.google.com/identity/protocols/oauth2/scopes
            //
            // TODO: With the SDK, we requested:
            //
            // - email
            // - profile
            // - https://www.googleapis.com/auth/userinfo.email
            // - https://www.googleapis.com/auth/userinfo.profile
            // - openid
            .init(name: "scope", value: "https://www.googleapis.com/auth/userinfo.email"),
            // TODO: make code_challenge and code_challenge_method come from the object
            .init(name: "code_challenge", value: pkce.codeCallenge),
            .init(name: "code_challenge_method", value: "plain")
        ]

        guard let authURL = URL(string: googleAuthBaseURL)?.appending(queryItems: queryItems) else {
            // FIXME: Proper error handling
            return
        }
        let scheme = ApiCredentials.googleLoginSchemeId

        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { [weak self] result in
            // FIXME: Do proper stuff!
            switch result {
            case .failure(let error):
                // IRL, this should bubble up the error to the caller so they can handle it.
                self?.presentAlert(title: "Auth failure", message: error.localizedDescription, onDismiss: {})
            case .success(let url):
                self?.requestOAuthToken(url: url) { result in
                    switch result {
                    case .success(let token):
                        print(token)
                        // Next step: Call https://www.googleapis.com/oauth2/v2/userinfo with the
                        // token and get
                        //
                        // - email
                        // - idToken (which is actually from previous response)
                        // - what else??
                        //
                        // See GoogleAuthenticator didSignIn(for:, error:)
                        //
                        // The library passes the GIDUser object received from Google to the caller.
                        // Do we still need to do that, but with a custom type we defined?
                        // If so, which information should we pass?
                        self?.presentAlert(title: "🎉", message: "Got a token back from Google", onDismiss: {})
                    case .failure(let error):
                        // IRL, this should bubble up the error to the caller so they can handle it.
                        self?.presentAlert(title: "Auth failure", message: error.localizedDescription, onDismiss: {})
                    }
                }
            }
        }

        session.presentationContextProvider = self
        // FIXME: should this be configurable and/or defaulting to what?
        session.prefersEphemeralWebBrowserSession = false

        session.start()
    }

    // https://developers.google.com/identity/protocols/oauth2/native-app#exchange-authorization-code
    private func requestOAuthToken(url: URL, onCompletion: @escaping (Result<String, Error>) -> Void) {
        // The SDK creates additional parameters:
        //
        /*
         audience = "<client id>.apps.googleusercontent.com";
         "device_os" = "iOS 16.1";
         "emm_support" = 1;
         gpsdk = "gid-6.0.1";
         */

        // FIXME: Handle the code not being found
        let authCode = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            .queryItems!
            .first(where: { $0.name == "code" })!
            .value!

        // FIXME: Avoid force try
        var request = try! URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!, method: .post)

        let body = OAuthTokenRequestBody(
            clientId: ApiCredentials.googleLoginClientId,
            // "The client secret obtained from the API Console Credentials page."
            // - https://developers.google.com/identity/protocols/oauth2/native-app#step-2:-send-a-request-to-googles-oauth-2.0-server
            //
            // There doesn't seem to be any secret for iOS app credentials.
            // The process works with an empty string...
            clientSecret: "",
            code: authCode,
            codeVerifier: pkce.codeVerifier,
            // TODO: This might be hardcoded...
            //
            // As defined in the OAuth 2.0 specification, this field's value must be set to authorization_code.
            // – https://developers.google.com/identity/protocols/oauth2/native-app#exchange-authorization-code
            grantType: "authorization_code",
            redirectURI: googleAuthRedirectURL(from: ApiCredentials.googleLoginClientId)
        )

        // See OIDTokenRequest line 272 at 1b0c4ec33a6fe282f4fa35d8ac64263230ddaf36
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.asURLEncodedData()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let d = data {
                print(String(data: d, encoding: .utf8))
            }
            guard let data, let tokenResponse: OAuthTokenResponseBody = try? JSONDecoder().decode(OAuthTokenResponseBody.self, from: data) else {
                print("data: \(String(describing: data))")
                print("response: \(String(describing: response))")
                print("error: \(String(describing: error))")
                // FIXME: Need better error handling here, hey!
                onCompletion(.failure(error!))
                return
            }

            onCompletion(.success(tokenResponse.accessToken))
        }

        task.resume()
    }
}

extension ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

// TODO: Make this throw?
private func googleAuthRedirectURL(from clientID: String) -> String {
    // Google's client id is in the form:
    //
    // 123-abc245def.apps.googleusercontent.com
    //
    // For this, we want only 123-abc245def
    // FIXME: Handle error, don't `first!`
    let uniqueComponent = String(clientID.split(separator: ".").first!)

    // GIDSignIn.m line 421 at 1b0c4ec33a6fe282f4fa35d8ac64263230ddaf36
    return "com.googleusercontent.apps.\(uniqueComponent):/oauth2callback"
}

// FIXME: Use a 128 lenght high entropy string and s256 mode
let pkce = ProofKeyForCodeExchange(
    codeVerifier: (0..<43).map { "a\($0)" }.joined(),
    mode: .plain
)
