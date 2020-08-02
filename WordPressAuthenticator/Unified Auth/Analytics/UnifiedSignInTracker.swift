import Foundation

class UnifiedSignInTracker {
    enum EventType: String {
        case step = "unified_login_step"
        case interaction = "unified_login_interaction"
        case failure = "unified_login_failure"
    }
    
    enum Source: String {
        case `default`
        case jetpack
        case share
        case deeplink
        case reauthetication
        
        /// Starts when the used adds a site from the site picker
        ///
        case selfHosted
    }
    
    enum Flow: String {
        /// The initial flow before we decide whether the user is logging in or signing up
        case wpCom = "wordpress_com"
        
        /// The flow that starts when the user starts the Google login
        ///
        case googleLogin = "google_login"
        
        case googleSignup = "google_signup"
        
        /// Flow for Sign in with Apple
        ///
        case apple = "siwa_login"
        
        /// Sign in with the icloud keychain
        ///
        case keychain = "icloud_keychain_login"
        
        /// The flow that starts when we offer the user the magic link login
        ///
        case magicLink = "login_magic_link"
        
        /// This flow starts when the user decides to login with a password instead
        ///
        case loginWithPassword = "login_password"
        
        /// This flow starts when the user decides to log in with their site address
        ///
        case loginWithSiteAddress = "login_site_address"
        
        /// This flow represents the signup (when the user inputs an email that’s not registered with a .com account)
        ///
        case signup
    }
    
    enum Step: String {
        /// Gets shown on the Prologue screen
        ///
        case prologue
        
        /// Triggered when a flow is started
        ///
        case start
        
        /// Triggered when a user requests a magic link and sees the screen with the “Open mail” button
        ///
        case magicLinkRequested = "magic_link_requested"
        
        /// This represents the user opening their mail. It’s not strictly speaking an in-app screen but for the user it is part of the flow.
        case emailOpened = "email_opened"
        
        /// The screen with a username and password visible
        ///
        case userPasswordScreenShown = "username_password"
        
        /// Triggered on the epilogue screen
        ///
        case success
        
        /// Triggered on the help screen
        ///
        case help
        
        /// When we ask user to input the code from the 2 factor authentication
        case twoFactorAuthentication = "2fa"
    }
    
    enum Interaction: String {
        /// Tracked when submitting the email form, the email & password form, site address form,
        /// username & password form and signup email form
        ///
        case submit
        
        /// Tracked when the user clicks on continue in the login/signup epilogue
        ///
        case `continue`
        
        /// Tracked when the post signup interstitial screen is dismissed, when the
        /// login signup help dialog is dismissed and when the email hint dialog is dismissed
        ///
        case dismiss
        
        /// Tracked when the user clicks “Continue with WordPress.com” on the Prologue screen
        ///
        case continueWithWordPressCom = "continue_with_wordpress_com"
        
        /// Tracked when the user clicks “Login with site address” on the Prologue screen
        ///
        case loginWithSiteAddress = "login_with_site_address"
        
        /// Tracked when the user clicks “Login with Google” on the WordPress.com flow screen
        ///
        case loginWithGoogle = "login_with_google"
        
        /// When the user clicks on “Forgotten password” on one of the screens that show the password field
        ///
        case forgottenPassword = "forgotten_password"
        
        /// When the user clicks on terms of service anywhere
        ///
        case termsOfService = "terms_of_service_clicked"
        
        /// When the user tries to sign up with email from the confirmation screen
        ///
        case signUpWithEmail = "signup_with_email"
        
        /// When the user tries to sign up with Google from the confirmation screen
        ///
        case signUpWithGoogle = "signup_with_google"
        
        /// When the user opens the email client from the magic link screen
        ///
        case openEmailClient = "open_email_client"
        
        /// Any time the user clicks on the help icon in the login flow
        ///
        case showHelp = "show_help"
        
        /// Used on the 2FA screen to send code with a text instead of using the authenticator app
        ///
        case sendCodeWithText = "send_code_with_text"
        
        /// Used on the 2FA screen to submit authentication code
        ///
        case submitTwoFactorCode = "submit_2fa_code"
        
        /// When the user requests a magic link after filling in email address
        ///
        case requestMagicLink = "request_magic_link"
        
        /// Used on the magic link screen to use password instead of magic link
        ///
        case loginWithPassword = "login_with_password"
        
        /// Click on “Create new site” button after a successful signup
        ///
        case createNewSite = "create_new_site"
        
        /// Adding a self-hosted site from the epilogue
        ///
        case addSelfHostedSite = "add_self_hosted_site"
        
        /// Connecting a site from the epilogue
        ///
        case connectSite = "connect_site"
        
        /// Picking an avatar from the epilogue after a successful signup
        ///
        case selectAvatar = "select_avatar"
        
        /// Editing the username from the epilogue after a successful signup
        ///
        case editUsername = "edit_username"
        
        /// Clicking on “Need help finding site address” from a dialog
        ///
        case helpFindingSiteAddress = "help_finding_site_address"
        
        /// When the user clicks on the email field to log in, this triggers the hint dialog to show up
        ///
        case selectEmailField = "select_email_field"
        
        /// When the user selects an email from the hint dialog
        ///
        case pickEmailFromHint = "pick_email_from_hint"
        
        /// When the user clicks on “Create account” on the signup confirmation screen
        ///
        case createAccount = "create_account"
    }
    
    class Context {
        var lastFlow: Flow
        var lastSource: Source
        var lastStep: Step
        
        init(lastFlow: Flow = .wpCom, lastSource: Source = .default, lastStep: Step = .prologue) {
            self.lastFlow = lastFlow
            self.lastSource = lastSource
            self.lastStep = lastStep
        }
    }
    
    let context: Context
    
    // MARK: - Initializers
    
    init(context: Context) {
        self.context = context
    }
    
    // MARK: - Tracking
    
    func track(_ event: AnalyticsEvent) {
        WPAnalytics.track(event)
    }
    
    func track(step: Step, flow: Flow) {
        track(event(step: step, flow: flow))
    }
    
    func track(failure: String) {
        track(event(failure: failure))
    }
    
    // MARK: - Event Construction & Context Updating
    
    private func event(step: Step, flow: Flow) -> AnalyticsEvent {
        let event = AnalyticsEvent(
            name: EventType.step.rawValue,
            properties: properties(step: step, flow: flow))
        
        saveLastProperties(step: step, flow: flow)
        
        return event
    }

    private func event(failure: String) -> AnalyticsEvent {
        return AnalyticsEvent(
            name: EventType.failure.rawValue,
            properties: lastProperties())
    }
    
    private func event(interaction: Interaction) -> AnalyticsEvent {
        return AnalyticsEvent(
            name: EventType.interaction.rawValue,
            properties: lastProperties())
    }
    
    // MARK: - Source Interactions
    
    func set(source: Source) {
        context.lastSource = source
    }
    
    // MARK: - Properties
    
    private func properties(step: Step, flow: Flow) -> [String: String] {
        return properties(step: step, flow: flow, source: context.lastSource)
    }
    
    private func properties(step: Step, flow: Flow, source: Source) -> [String: String] {
        return [
            "flow": flow.rawValue,
            "source": source.rawValue,
            "step": step.rawValue,
        ]
    }
    
    // MARK: - Properties: state machine
    
    private func lastProperties() -> [String: String] {
        return properties(step: context.lastStep, flow: context.lastFlow, source: context.lastSource)
    }
    
    private func saveLastProperties(step: Step, flow: Flow) {
        context.lastFlow = flow
        context.lastStep = step
    }
}
