import Foundation


/// Provides options for clients of WordPressAuthenticator
/// to signal what they expect WPAuthenticator to do in response to
/// `sync`
///
public enum WordPressAuthenticatorSyncAccountResult {

    /// A view controller to be inserted into the navigation stack
    ///
    case injectViewController(value: UIViewController)

    /// The account sync process
    case success
}
