// https://developers.google.com/identity/protocols/oauth2/native-app#step1-code-verifier
//
// FIXME: follow spec!
//
// A code_verifier is a high-entropy cryptographic random string using the unreserved
// characters [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~", with a minimum length of 43
// characters and a maximum length of 128 characters.
//
//
// The code verifier should have enough entropy to make it impractical to guess the value.
struct ProofKeyForCodeExchange {

    enum Mode {
        case s256
        case plain
    }

    let codeVerifier: String
    let mode: Mode

    init(codeVerifier: String, mode: Mode) {
        self.codeVerifier = codeVerifier
        self.mode = mode
    }

    var codeCallenge: String {
        switch mode {
        case .s256:
            // TODO: code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
            fatalError()
        case .plain:
            return codeVerifier
        }
    }
}
