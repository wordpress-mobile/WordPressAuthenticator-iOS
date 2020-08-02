import Foundation

public class WordPressAuthenticatorTracker {
    
    private let authConfig: WordPressAuthenticatorConfiguration
    private let tracker = UnifiedSignInTracker(context: UnifiedSignInTracker.Context())
    
    public init(authConfig: WordPressAuthenticatorConfiguration) {
        self.authConfig = authConfig
    }
    
    // MARK: -  Tracking: support
    
    func track(_ event: WPAnalyticsStat, properties: [AnyHashable: Any] = [:]) {
        WordPressAuthenticator.track(event, properties: properties)
    }
    
    func track(_ event: AnalyticsEvent) {
        WPAnalytics.track(event)
    }
    
    // MARK: - Specific Events
    
    public func trackPrologueViewed() {
        // Legacy tracking
        track(.loginPrologueViewed)
        
        // Unified tracking
        tracker.set(source: .default)
        tracker.track(step: .prologue, flow: .wpCom)
    }
    
    public func trackSignUpButtonTapped() {
        // Legacy tracking
        // This stat is part of a funnel that provides critical information.
        // Before making ANY modification to this stat please refer to: p4qSXL-35X-p2
        track(.signupButtonTapped)
        
        // Unified Tracking
    }
}
