import Foundation
import AuthenticationServices

/// The authorization flow handled by this class starts by showing Apple's `ASAuthorizationController`
/// through our class `StoredCredentialsPicker`.  This controller lets the user pick the credentials they
/// want to login with.  This class handles both showing that controller and executing the remaining flow to
/// complete the login process.
///
@available(iOS 13, *)
class StoredCredentialsAuthenticator: NSObject {

    // MARK: - Delegates
    
    private var authenticationDelegate: WordPressAuthenticatorDelegate {
        guard let delegate = WordPressAuthenticator.shared.delegate else {
            fatalError()
        }
        return delegate
    }
    
    // MARK: - Configuration

    private var authConfig: WordPressAuthenticatorConfiguration {
        WordPressAuthenticator.shared.configuration
    }

    // MARK: - Login Support
    
    private lazy var loginFacade: LoginFacade = {
        let facade = LoginFacade(dotcomClientID: authConfig.wpcomClientId,
                                 dotcomSecret: authConfig.wpcomSecret,
                                 userAgent: authConfig.userAgent)
        facade.delegate = self
        return facade
    }()
    
    // MARK: - UI
    
    private let picker = StoredCredentialsPicker()
    private var navigationController: UINavigationController?
    
    // MARK: - Tracking Support

    private var tracker: AuthenticatorAnalyticsTracker {
        AuthenticatorAnalyticsTracker.shared
    }
    
    // MARK: - Picker
    
    /// Shows the UI for picking stored credentials for the user to log into their account.
    ///
    func showPicker(from navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        guard let window = navigationController.view.window else {
            DDLogError("Can't obtain window for navigation controller")
            return
        }
        
        tracker.set(flow: .loginWithiCloudKeychain)
        tracker.track(step: .start)
        
        picker.show(in: window) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let authorization):
                self.pickerSuccess(authorization)
            case .failure(let error):
                self.pickerFailure(error)
            }
        }
    }
    
    /// The selection of credentials and subsequent authorization by the OS succeeded.  This method processes the credentials
    /// and proceeds with the login operation.
    ///
    /// - Parameters:
    ///         - authorization: The authorization by the OS, containing the credentials picked by the user.
    ///
    private func pickerSuccess(_ authorization: ASAuthorization) {
        switch authorization.credential {
        case _ as ASAuthorizationAppleIDCredential:
            // No-op for now, but we can decide to implement AppleID login through this authenticator
            // by implementing the logic here.
            break
        case let credential as ASPasswordCredential:
            let loginFields = LoginFields.makeForWPCom(username: credential.user, password: credential.password)
            loginFacade.signIn(with: loginFields)
            break
        default:
            // There aren't any other known methods for us to handle here, but we still need to complete the switch
            // statement.
            break
        }
    }
    
    /// The selection of credentials or the subsequent authorization by the OS failed.  This method processes the failure.
    ///
    /// - Parameters:
    ///         - error: The error detailing what failed.
    ///
    private func pickerFailure(_ error: Error) {
        let authError = ASAuthorizationError(_nsError: error as NSError)

        switch authError.code {
        case .canceled:
            // The user cancelling the flow is not really an error, so we're not reporting or tracking
            // this as an error.  We're only tracking this as a regular UI dismissal.
            tracker.track(click: .dismiss)
        case .failed, .invalidResponse, .notHandled, .unknown:
            tracker.track(failure: authError.localizedDescription)
            DDLogError("ASAuthorizationError: \(authError.localizedDescription)")
        }
    }
}

@available(iOS 13, *)
extension StoredCredentialsAuthenticator: LoginFacadeDelegate {
    func needsMultifactorCode() {
    }

    func finishedLogin(withAuthToken authToken: String, requiredMultifactorCode: Bool) {
        let wpcom = WordPressComCredentials(
            authToken: authToken,
            isJetpackLogin: false,
            multifactor: requiredMultifactorCode,
            siteURL: "")
        let credentials = AuthenticatorCredentials(wpcom: wpcom)
        
        authenticationDelegate.sync(credentials: credentials) { [weak self] in
            self?.presentLoginEpilogue(credentials: credentials)
        }
    }
}

// MARK: - UI Flow

@available(iOS 13, *)
extension StoredCredentialsAuthenticator {
    func presentLoginEpilogue(credentials: AuthenticatorCredentials) {
        guard let navigationController = self.navigationController else {
            DDLogError("No navigation controller to present the login epilogue from")
            return
        }
        
        authenticationDelegate.presentLoginEpilogue(in: navigationController, for: credentials, onDismiss: {})
    }
}
