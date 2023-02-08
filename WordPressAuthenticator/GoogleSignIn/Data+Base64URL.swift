extension Data {

    /// "base64url" is an encoding that is safe to use with URLs.
    /// It is defined in RFC 4648, section 5.
    ///
    /// See:
    /// - https://tools.ietf.org/html/rfc4648#section-5
    /// - https://tools.ietf.org/html/rfc7515#appendix-C
    init(base64URLDecode: String) {
        let base64 = base64URLDecode
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            self.init(base64Encoded: base64 + padding, options: .ignoreUnknownCharacters)!
        } else {
            self.init(base64Encoded: base64, options: .ignoreUnknownCharacters)!
        }
    }
}
