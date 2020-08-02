import Foundation

public class WordPressAuthenticatorTracker {
    
    private let authConfig: WordPressAuthenticatorConfiguration
    private let signInTracker: SignInTracker
    
    var context: SignInTracker.Context {
        return signInTracker.context
    }
    
    public init(authConfig: WordPressAuthenticatorConfiguration, context: SignInTracker.Context) {
        self.authConfig = authConfig
        self.signInTracker = SignInTracker(context: context)
    }
    
    // MARK: -  Tracking: support
    
    func track(_ event: WPAnalyticsStat, properties: [AnyHashable: Any] = [:]) {
        WordPressAuthenticator.track(event, properties: properties)
    }
    
    // MARK: - Specific Events
    
    public func trackPrologueViewed() {
        // Legacy tracking
        track(.loginPrologueViewed)
        
        // Unified tracking
        signInTracker.set(source: .default)
        signInTracker.track(step: .prologue, flow: .wpCom)
    }
    
    public func trackSignUpButtonTapped() {
        // Legacy tracking
        // This stat is part of a funnel that provides critical information.
        // Before making ANY modification to this stat please refer to: p4qSXL-35X-p2
        track(.signupButtonTapped)
        
        // Unified Tracking
    }
}
