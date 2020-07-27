// MARK: - Analytic Events

extension GoogleAuthenticatorTracker {
    enum GoogleLoginStep: String {
        case start
        case twoFactorAuthentication
        case success
    }
    
    // MARK: - Login
    
    static func login(step: GoogleLoginStep) -> AnalyticsEvent {
        let properties = [
            "source": "default",
            "flow": "google_login",
            "step": step.rawValue,
        ]
        
        return AnalyticsEvent(name: "unified_login_step", properties: properties)
    }
    
    static func loginFailure(step: GoogleLoginStep, message: String) -> AnalyticsEvent {
        let properties = [
            "source": "default",
            "flow": "google_login",
            "step": step.rawValue,
            "failure": message,
        ]
        
        return AnalyticsEvent(name: "unified_login_failure", properties: properties)
    }
    
    // MARK: - SignUp
    
    static func signUp(step: GoogleLoginStep) -> AnalyticsEvent {
        let properties = [
            "source": "default",
            "flow": "google_signup",
            "step": step.rawValue,
        ]
        
        return AnalyticsEvent(name: "unified_login_step", properties: properties)
    }
    
    static func signUpFailure(step: GoogleLoginStep, message: String) -> AnalyticsEvent {
        let properties = [
            "source": "default",
            "flow": "google_signup",
            "step": step.rawValue,
            "failure": message,
        ]
        
        return AnalyticsEvent(name: "unified_login_failure", properties: properties)
    }
}
