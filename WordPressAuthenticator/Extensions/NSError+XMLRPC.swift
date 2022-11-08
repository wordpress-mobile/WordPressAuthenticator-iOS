import Foundation
import WordPressKit

/// Helper methods for XMLRPC validation related errors
///
extension NSError {
    func extractXMLRPCError() -> NSError {
        guard let err = userInfo[XMLRPCOriginalErrorKey] as? NSError else {
            return self
        }

        return err
    }

    func errorMessage() -> String? {
        if let xmlrpcValidatorError = self as? WordPressOrgXMLRPCValidatorError {
            return xmlrpcValidatorError.localizedDescription
        } else if (domain == NSURLErrorDomain && code == NSURLErrorCannotFindHost) ||
                    (domain == NSURLErrorDomain && code == NSURLErrorNetworkConnectionLost) {
            // NSURLErrorNetworkConnectionLost can be returned when an invalid URL is entered.
           return NSLocalizedString(
                "The site at this address is not a WordPress site. For us to connect to it, the site must use WordPress.",
                comment: "Error message shown a URL does not point to an existing site.")
        }

        return nil
    }
}
