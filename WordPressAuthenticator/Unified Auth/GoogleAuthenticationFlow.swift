import Combine
import AuthenticationServices

struct GoogleAuthenticationCredentials {
    let clientID: String
    let clientSecret: String
    let redirectURI: String
}

final class GoogleAuthenticationFlow {

    private var cancellable: AnyCancellable? = nil
    private var cancellableToken: AnyCancellable? = nil

    private let codeChallenge = UUID().uuidString

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
        cancellable = fetchAuthorizationCode().flatMap { url in
            self.fetchAuthorizationToken(url: url)
        }.eraseToAnyPublisher().sink { error in
            switch error {
            case .failure(let error):
                //onCompletion(.failure(error))
            print("==== error ", error)
            default:
                print("==== default ")
                break
            }
        } receiveValue: { url in
            //onCompletion(.success(intent))
            print("==== end result ", url)
        }
    }

    private func fetchAuthorizationCode() -> Future<URL, Error> {

        return Future<URL, Error> { [weak self] completion in
            guard let self = self else {
                completion(.failure(NSError()))
                return
            }
            let url = self.googleAuthorizationUrl(withClientID: self.credentials.clientID, redirectURI: self.credentials.redirectURI)
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: self.credentials.redirectURI) { (url, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    print("=== success url ", url)
                    completion(.success(url))
                } else {
                    fatalError("This shouldn't be possible (but we should emit an 'unknown login error' instead of crashing")
                }
            }

            session.presentationContextProvider = self.contextProvider

            session.start()
        }
    }

    private func fetchAuthorizationToken(url: URL) -> Future<GoogleToken, Error> {
        return Future<GoogleToken, Error> { [weak self] completion in
            guard let self = self else {
                completion(.failure(NSError()))
                return
            }
            let code = url["code"]
            print("=== code ", code)
            let url = self.googleTokenUrl(withClientID: self.credentials.clientID, clientSecret: self.credentials.clientSecret, redirectURI: self.credentials.redirectURI , code: code!)
            print("==== url ", url)
            let request = try! URLRequest(url: url, method: .post)
            self.cancellableToken = URLSession.shared.dataTaskPublisher(for: request).tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                            httpResponse.statusCode == 200 else {
                                throw URLError(.badServerResponse)
                            }
                return element.data
            }.decode(type: GoogleToken.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sink(receiveCompletion: {
                    print ("Received completion: \($0).")

            },
                      receiveValue: { token in
                        print ("Received user: \(token).")})
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
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "plain")
        ]

        return try! components.asURL()
    }

    func googleTokenUrl(withClientID clientID: String, clientSecret: String, redirectURI: String, code: String) -> URL {
        print("===== client secret ", clientSecret)
        var components = URLComponents(string: "https://accounts.google.com/token")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "code_verifier", value: codeChallenge),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
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


private extension URL {
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}


struct GoogleToken: Decodable {
    public let authToken: String

    public init(authToken: String) {
        self.authToken = authToken
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let token = try container.decode(String.self, forKey: .accessToken)

        self.init(authToken: token)
    }
}


private extension GoogleToken {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
