import Foundation

/// Provides all the business logic for tracking Google Authentication events.
///
class GoogleAuthenticatorTracker {
    
    private let authConfig: WordPressAuthenticatorConfiguration
    let tracker = UnifiedSignInTracker(context: UnifiedSignInTracker.Context())
    
    init(authConfig: WordPressAuthenticatorConfiguration) {
        self.authConfig = authConfig
    }
    
    // MARK: -  Tracking: support
    
    func track(_ event: WPAnalyticsStat, properties: [AnyHashable: Any] = [:]) {
        guard authConfig.enableUnifiedGoogle else {
            var trackProperties = properties
            trackProperties["source"] = "google"
            WordPressAuthenticator.track(event, properties: trackProperties)
            return
        }
        
        WordPressAuthenticator.track(event, properties: properties)
    }
    
    // MARK: - Tracking: Specific Events
    
    func track(_ event: AnalyticsEvent) {
        WPAnalytics.track(event)
    }
    
    /// Tracks the start of the sign-in flow.
    ///
    func trackSignInStart(authType: GoogleAuthType) {
        guard authConfig.enableUnifiedGoogle else {
            switch authType {
            case .login:
                track(.loginSocialButtonClick)
            case .signup:
                track(.createAccountInitiated)
            }
            
            return
        }
        
        switch authType {
        case .login:
            trackLogin(step: .start)
        case .signup:
            trackSignup(step: .start)
        }
    }
    
    /// Tracks a change of flow from signup to login.
    ///
    func trackLoginInstead() {
        guard authConfig.enableUnifiedGoogle else {
            track(.signupSocialToLogin)
            track(.signedIn)
            track(.loginSocialSuccess)
            return
        }
        
        trackLogin(step: .start)
        trackLogin(step: .success)
    }
    
    /// Tracks the request of a 2FA code to the user.
    ///
    func trackTwoFactorAuhenticationRequested(authType: GoogleAuthType) {
        guard authConfig.enableUnifiedGoogle else {
            track(.loginSocial2faNeeded)
            return
        }
        
        trackLogin(step: .twoFactorAuthentication)
    }
    
    /// Tracks a successful signin.
    ///
    func trackSignInSuccess(authType: GoogleAuthType) {
        guard authConfig.enableUnifiedGoogle else {
            track(.signedIn)
            track(.loginSocialSuccess)
            return
        }
        
        switch authType {
        case .login:
            trackLogin(step: .success)
        case .signup:
            trackSignup(step: .success)
        }
    }

    /// Tracks a failure in any step of the signin process.
    ///
    func trackSignInFailure(authType: GoogleAuthType, error: Error?) {
        let errorMessage = error?.localizedDescription ?? "Unknown error"
        
        guard authConfig.enableUnifiedGoogle else {
            // The Google SignIn may have been cancelled.
            let properties = ["error": errorMessage]

            switch authType {
            case .login:
                track(.loginSocialButtonFailure, properties: properties)
            case .signup:
                track(.signupSocialButtonFailure, properties: properties)
            }
            
            return
        }
        
        // Note for reviewer (will be removed before merging): I'm not sure if these should be
        // login and signup failure, or if these should be the upcoming click-tracking errors
        // as the ones recorded here: https://github.com/wordpress-mobile/WordPress-Android/pull/12117
        //
        // My take is that these are login errors
        
        trackFailure(failure: errorMessage)
    }
    
    func trackSignUpFailure(error: Error) {
        let errorMessage = error.localizedDescription
        
        guard authConfig.enableUnifiedGoogle else {
            track(.signupSocialFailure, properties: ["error": errorMessage])
            return
        }
        
        trackFailure(failure: errorMessage)
    }
}

// MARK: - Tracking Convenience Methods

extension GoogleAuthenticatorTracker {
    
    func trackLogin(step: UnifiedSignInTracker.Step) {
        tracker.track(step: step, flow: .googleLogin)
    }
    
    func trackSignup(step: UnifiedSignInTracker.Step) {
        tracker.track(step: step, flow: .googleSignup)
    }
    
    func trackFailure(failure: String) {
        tracker.track(failure: failure)
    }
}
