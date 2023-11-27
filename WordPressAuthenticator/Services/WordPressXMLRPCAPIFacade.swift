import Foundation
import WordPressKit

public extension WordPressXMLRPCAPIFacade {

    @objc(parseGuessXMLRPCAPIFailure:)
    func parseGuessXMLRPCAPIFailure(_ error: Error) -> Error {
        WPAuthenticatorLogError("Error on trying to guess XMLRPC site: \(error)")

        if let urlError = error as? URLError, [.userCancelledAuthentication, .notConnectedToInternet, .networkConnectionLost].contains(urlError.code) {
            return error
        }

        return WordPressAuthenticatorError.xmlrpcUnavailable(underlyingError: error)
    }

}
