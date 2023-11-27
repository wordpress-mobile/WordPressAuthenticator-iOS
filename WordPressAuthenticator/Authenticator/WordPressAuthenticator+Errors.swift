import Foundation

enum WordPressAuthenticatorError: Error {
    case xmlrpcUnavailable
}

extension WordPressAuthenticatorError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .xmlrpcUnavailable:
            return NSLocalizedString(
                "We're not able to connect to the Jetpack site at that URL.  Contact us for assistance.",
                comment: "Error message shown when having trouble connecting to a Jetpack site."
            )
        }
    }

}

// MARK: - WordPressAuthenticator Error Constants.
//
extension WordPressAuthenticator {

    /// Error Domain for Authentication issues.
    ///
    @objc public static let errorDomain = "org.wordpress.ios.authenticator"

    /// "Invalid Version" Error Code. Used whenever the remote WordPress.org endpoint is below the supported version.
    ///
    @objc public static let invalidVersionErrorCode = 5000
}
