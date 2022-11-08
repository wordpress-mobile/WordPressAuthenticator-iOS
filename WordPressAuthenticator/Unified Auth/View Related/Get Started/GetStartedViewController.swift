import UIKit
import SafariServices
import WordPressKit

/// The source for the sign in flow for external tracking.
public enum SignInSource: Equatable {
    /// Initiated from the WP.com login CTA.
    case wpCom
    /// Initiated from the WP.com login flow that starts with site address.
    case wpComSiteAddress
    /// Other source identifier from the host app.
    case custom(source: String)
}

/// The error during the sign in flow.
public enum SignInError: Error {
    case invalidWPComEmail(source: SignInSource)
    case invalidWPComPassword(source: SignInSource)

    init?(error: Error, source: SignInSource?) {
        let error = error as NSError

        switch error.code {
        case WordPressComRestApiError.unknown.rawValue:
            let restAPIErrorCode = error.userInfo[WordPressComRestApi.ErrorKeyErrorCode] as? String
            if let source = source, restAPIErrorCode == "unknown_user" {
                self = .invalidWPComEmail(source: source)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

/// Error due to site's `xmlrpc.php` file not being public
///
public enum XMLRPCError: Error {
    case xmlrpcError(siteAddress: String)
}

class GetStartedViewController: LoginViewController, NUXKeyboardResponder {

    private enum ScreenMode {
        /// For signing in using .org site credentials
        ///
        case signInUsingSiteCredentials

        /// For signing in using WPCOM credentials or social accounts
        case signInUsingWordPressComOrSocialAccounts
    }

    // MARK: - NUXKeyboardResponder constraints
    @IBOutlet var bottomContentConstraint: NSLayoutConstraint?

    // Required for `NUXKeyboardResponder` but unused here.
    var verticalCenterConstraint: NSLayoutConstraint?

    // MARK: - Properties
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var leadingDividerLine: UIView!
    @IBOutlet private weak var leadingDividerLineWidth: NSLayoutConstraint!
    @IBOutlet private weak var dividerStackView: UIStackView!
    @IBOutlet private weak var dividerLabel: UILabel!
    @IBOutlet private weak var trailingDividerLine: UIView!
    @IBOutlet private weak var trailingDividerLineWidth: NSLayoutConstraint!

    private weak var emailField: UITextField?
    // This is to contain the password selected by password auto-fill.
    // When it is populated, login is attempted.
    @IBOutlet private weak var hiddenPasswordField: UITextField?

    // This is public so it can be set from StoredCredentialsAuthenticator.
    var errorMessage: String?

    var source: SignInSource? {
        didSet {
            WordPressAuthenticator.shared.signInSource = source
        }
    }

    private var rows = [Row]()
    private var buttonViewController: NUXButtonViewController?
    private let configuration = WordPressAuthenticator.shared.configuration
    private var shouldChangeVoiceOverFocus: Bool = false

    private var passwordCoordinator: PasswordCoordinator?

    /// Sign in with site credentials button will be displayed based on the `screenMode`
    ///
    private var screenMode: ScreenMode {
        guard configuration.enableSiteCredentialsLoginForSelfHostedSites,
              loginFields.siteAddress.isEmpty == false else {
            return .signInUsingWordPressComOrSocialAccounts
        }
        return .signInUsingSiteCredentials
    }

    // Submit button displayed in the table footer.
    private lazy var continueButton: NUXButton = {
        let button = NUXButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isPrimary = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSubmitButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ButtonConfiguration.Continue.accessibilityIdentifier
        button.setTitle(ButtonConfiguration.Continue.title, for: .normal)

        return button
    }()

    // "What is WordPress.com?" button
    private lazy var whatisWPCOMButton: UIButton = {
        let button = UIButton()
        button.setTitle(WordPressAuthenticator.shared.displayStrings.whatIsWPComLinkTitle, for: .normal)
        let buttonTitleColor = WordPressAuthenticator.shared.unifiedStyle?.textButtonColor ?? WordPressAuthenticator.shared.style.textButtonColor
        let buttonHighlightColor = WordPressAuthenticator.shared.unifiedStyle?.textButtonHighlightColor ?? WordPressAuthenticator.shared.style.textButtonHighlightColor
        button.titleLabel?.font = WPStyleGuide.mediumWeightFont(forStyle: .subheadline)
        button.setTitleColor(buttonTitleColor, for: .normal)
        button.setTitleColor(buttonHighlightColor, for: .highlighted)
        button.addTarget(self, action: #selector(whatIsWPComButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    private var showsContinueButtonAtTheBottom: Bool {
        screenMode == .signInUsingSiteCredentials ||
            configuration.enableSocialLogin == false
    }

    override open var sourceTag: WordPressSupportSourceTag {
        get {
            return .loginEmail
        }
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        setupTable()
        registerTableViewCells()
        loadRows()
        setupTableFooterView()
        configureDivider()

        if screenMode == .signInUsingSiteCredentials {
            configureButtonViewControllerForSiteCredentialsMode()
        } else if configuration.enableSocialLogin == false {
            configureButtonViewControllerWithoutSocialLogin()
        } else {
            configureSocialButtons()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshEmailField()

        // Ensure the continue button matches the validity of the email field
        configureContinueButton(animating: false)

        if errorMessage != nil {
            shouldChangeVoiceOverFocus = true
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configureAnalyticsTracker()

        errorMessage = nil
        hiddenPasswordField?.text = nil
        hiddenPasswordField?.isAccessibilityElement = false

        if showsContinueButtonAtTheBottom {
            registerForKeyboardEvents(keyboardWillShowAction: #selector(handleKeyboardWillShow(_:)),
                                      keyboardWillHideAction: #selector(handleKeyboardWillHide(_:)))
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardEvents()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.updateFooterHeight()
    }

    // MARK: - Overrides

    override func styleBackground() {
        guard let unifiedBackgroundColor = WordPressAuthenticator.shared.unifiedStyle?.viewControllerBackgroundColor else {
            super.styleBackground()
            return
        }

        view.backgroundColor = unifiedBackgroundColor
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return WordPressAuthenticator.shared.unifiedStyle?.statusBarStyle ??
            WordPressAuthenticator.shared.style.statusBarStyle
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let vc = segue.destination as? NUXButtonViewController {
            buttonViewController = vc
        }
    }

    override func configureViewLoading(_ loading: Bool) {
        configureContinueButton(animating: loading)
        navigationItem.hidesBackButton = loading
    }

    override func enableSubmit(animating: Bool) -> Bool {
        return !animating && canSubmit()
    }

    private func refreshEmailField() {
        // It's possible that the password screen could have changed the loginFields username, for example when using
        // autofill from a password manager. Let's ensure the loginFields matches the email field.
        loginFields.username = emailField?.nonNilTrimmedText() ?? loginFields.username
    }
}

// MARK: - UITableViewDataSource

extension GetStartedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        configure(cell, for: row, at: indexPath)
        return cell
    }

}

// MARK: - Private methods

private extension GetStartedViewController {

    // MARK: - Configuration

    func configureNavBar() {
        navigationItem.title = WordPressAuthenticator.shared.displayStrings.getStartedTitle
        styleNavigationBar(forUnified: true)
    }

    func setupTable() {
        defaultTableViewMargin = tableViewLeadingConstraint?.constant ?? 0
        setTableViewMargins(forWidth: view.frame.width)
    }

    func setupTableFooterView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Constants.FooterStackView.spacing
        stackView.layoutMargins = Constants.FooterStackView.layoutMargins
        stackView.isLayoutMarginsRelativeArrangement = true

        if showsContinueButtonAtTheBottom == false {
            // Continue button will be added to `buttonViewController` along with sign in with site credentials button when `screenMode` is `signInUsingSiteCredentials`
            // and simplified login flow is disabled.
            stackView.addArrangedSubview(continueButton)
        }

        if configuration.whatIsWPComURL != nil {
            let stackViewWithCenterAlignment = UIStackView()
            stackViewWithCenterAlignment.axis = .vertical
            stackViewWithCenterAlignment.alignment = .center

            stackViewWithCenterAlignment.addArrangedSubview(whatisWPCOMButton)

            stackView.addArrangedSubview(stackViewWithCenterAlignment)
        }

        tableView.tableFooterView = stackView
        tableView.updateFooterHeight()
    }

    /// Style the "OR" divider.
    ///
    func configureDivider() {
        guard showsContinueButtonAtTheBottom == false else {
            return dividerStackView.isHidden = true
        }
        let color = WordPressAuthenticator.shared.unifiedStyle?.borderColor ?? WordPressAuthenticator.shared.style.primaryNormalBorderColor
        leadingDividerLine.backgroundColor = color
        leadingDividerLineWidth.constant = WPStyleGuide.hairlineBorderWidth
        trailingDividerLine.backgroundColor = color
        trailingDividerLineWidth.constant = WPStyleGuide.hairlineBorderWidth
        dividerLabel.textColor = color
        dividerLabel.text = NSLocalizedString("Or", comment: "Divider on initial auth view separating auth options.").localizedUppercase
    }

    // MARK: - Continue Button Action

    @objc func handleSubmitButtonTapped() {
        tracker.track(click: .submit)
        validateForm()
    }

    // MARK: - Sign in with site credentials Button Action
    @objc func handleSiteCredentialsButtonTapped() {
        tracker.track(click: .signInWithSiteCredentials)
        guard WordPressAuthenticator.shared.configuration.checkXMLRPCOnlyIfSigningInUsingSiteCredentials else {
            // XMLRPC already checked in "Enter site address" screen.
            return goToSiteCredentialsScreen()
        }

        // Check XMLRPC before asking for site credentials.
        guessXMLRPCURL(for: loginFields.siteAddress)
    }

    // MARK: - What is WordPress.com Button Action

    @IBAction func whatIsWPComButtonTapped(_ sender: UIButton) {
        tracker.track(click: .whatIsWPCom)
        guard let whatIsWPCom = configuration.whatIsWPComURL,
              let url = URL(string: whatIsWPCom) else {
            return
        }
        UIApplication.shared.open(url)
    }

    // MARK: - Hidden Password Field Action

    @IBAction func handlePasswordFieldDidChange(_ sender: UITextField) {
        attemptAutofillLogin()
    }

    // MARK: - Table Management

    /// Registers all of the available TableViewCells.
    ///
    func registerTableViewCells() {
        let cells = [
            TextLabelTableViewCell.reuseIdentifier: TextLabelTableViewCell.loadNib(),
            TextFieldTableViewCell.reuseIdentifier: TextFieldTableViewCell.loadNib(),
            TextWithLinkTableViewCell.reuseIdentifier: TextWithLinkTableViewCell.loadNib()
        ]

        for (reuseIdentifier, nib) in cells {
            tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        }
    }

    /// Describes how the tableView rows should be rendered.
    ///
    func loadRows() {
        rows = [.instructions, .email]

        if let authenticationDelegate = WordPressAuthenticator.shared.delegate, authenticationDelegate.wpcomTermsOfServiceEnabled {
            rows.append(.tos)
        }

        if let errorText = errorMessage, !errorText.isEmpty {
            rows.append(.errorMessage)
        }
    }

    /// Configure cells.
    ///
    func configure(_ cell: UITableViewCell, for row: Row, at indexPath: IndexPath) {
        switch cell {
        case let cell as TextLabelTableViewCell where row == .instructions:
            configureInstructionLabel(cell)
        case let cell as TextFieldTableViewCell:
            configureEmailField(cell)
        case let cell as TextWithLinkTableViewCell:
            configureTextWithLink(cell)
        case let cell as TextLabelTableViewCell where row == .errorMessage:
            configureErrorLabel(cell)
        default:
            DDLogError("Error: Unidentified tableViewCell type found.")
        }
    }

    /// Configure the instruction cell.
    ///
    func configureInstructionLabel(_ cell: TextLabelTableViewCell) {
        cell.configureLabel(text: WordPressAuthenticator.shared.displayStrings.getStartedInstructions)
    }

    /// Configure the email cell.
    ///
    func configureEmailField(_ cell: TextFieldTableViewCell) {
        cell.configure(withStyle: .email,
                       placeholder: WordPressAuthenticator.shared.displayStrings.emailAddressPlaceholder,
                       text: loginFields.username)
        cell.textField.delegate = self
        emailField = cell.textField

        cell.onChangeSelectionHandler = { [weak self] textfield in
            self?.loginFields.username = textfield.nonNilTrimmedText()
            self?.configureContinueButton(animating: false)
        }

        if UIAccessibility.isVoiceOverRunning {
            // Quiet repetitive elements in VoiceOver.
            emailField?.placeholder = nil
        }
    }

    /// Configure the link cell.
    ///
    func configureTextWithLink(_ cell: TextWithLinkTableViewCell) {
        cell.configureButton(markedText: WordPressAuthenticator.shared.displayStrings.loginTermsOfService)

        cell.actionHandler = { [weak self] in
            self?.termsTapped()
        }
    }

    /// Configure the error message cell.
    ///
    func configureErrorLabel(_ cell: TextLabelTableViewCell) {
        cell.configureLabel(text: errorMessage, style: .error)

        if shouldChangeVoiceOverFocus {
            UIAccessibility.post(notification: .layoutChanged, argument: cell)
        }
    }

    /// Rows listed in the order they were created.
    ///
    enum Row {
        case instructions
        case email
        case tos
        case errorMessage

        var reuseIdentifier: String {
            switch self {
            case .instructions, .errorMessage:
                return TextLabelTableViewCell.reuseIdentifier
            case .email:
                return TextFieldTableViewCell.reuseIdentifier
            case .tos:
                return TextWithLinkTableViewCell.reuseIdentifier
            }
        }
    }

    enum Constants {
        enum FooterStackView {
            static let spacing = 16.0
            static let layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        }
    }

    // MARK: Analytics
    //
    func configureAnalyticsTracker() {
        // Configure tracker flow based on screen mode.
        switch screenMode {
        case .signInUsingSiteCredentials:
            tracker.set(flow: .loginWithSiteAddress)
        case .signInUsingWordPressComOrSocialAccounts:
            tracker.set(flow: .wpCom)
        }

        if isMovingToParent {
            tracker.track(step: .enterEmailAddress)
        } else {
            tracker.set(step: .enterEmailAddress)
        }
    }
}

// MARK: - Validation

private extension GetStartedViewController {

    /// Configures appearance of the submit button.
    ///
    func configureContinueButton(animating: Bool) {
        if showsContinueButtonAtTheBottom {
            buttonViewController?.setTopButtonState(isLoading: animating,
                                                    isEnabled: enableSubmit(animating: animating))
        } else {
            continueButton.showActivityIndicator(animating)
            continueButton.isEnabled = enableSubmit(animating: animating)
        }
    }

    /// Whether the form can be submitted.
    ///
    func canSubmit() -> Bool {
        return EmailFormatValidator.validate(string: loginFields.username)
    }

    /// Validates email address and proceeds with the submit action.
    /// Empties loginFields.meta.socialService as
    /// social signin does not require form validation.
    ///
    func validateForm() {
        loginFields.meta.socialService = nil
        displayError(message: "")

        guard EmailFormatValidator.validate(string: loginFields.username) else {
            present(buildInvalidEmailAlertGeneric(), animated: true, completion: nil)
            return
        }

        configureViewLoading(true)
        let service = WordPressComAccountService()
        service.isPasswordlessAccount(username: loginFields.username,
                                      success: { [weak self] passwordless in
                                        self?.configureViewLoading(false)
                                        self?.loginFields.meta.passwordless = passwordless
                                        passwordless ? self?.requestAuthenticationLink() : self?.showPasswordOrMagicLinkView()
            },
                                      failure: { [weak self] error in
                                        WordPressAuthenticator.track(.loginFailed, error: error)
                                        DDLogError(error.localizedDescription)
                                        guard let self = self else {
                                            return
                                        }
                                        self.configureViewLoading(false)

                                        self.handleLoginError(error)
        })
    }

    /// Show the Password entry view.
    ///
    func showPasswordView() {
        guard let vc = PasswordViewController.instantiate(from: .password) else {
            DDLogError("Failed to navigate to PasswordViewController from GetStartedViewController")
            return
        }

        vc.source = source
        vc.loginFields = loginFields
        vc.trackAsPasswordChallenge = false

        navigationController?.pushViewController(vc, animated: true)
    }

    /// Show the password or magic link view based on the configuration.
    ///
    func showPasswordOrMagicLinkView() {
        guard let navigationController = navigationController else {
            return
        }
        configureViewLoading(true)
        let coordinator = PasswordCoordinator(navigationController: navigationController,
                                              source: source,
                                              loginFields: loginFields,
                                              tracker: tracker,
                                              configuration: configuration)
        passwordCoordinator = coordinator
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            await coordinator.start()
            self.configureViewLoading(false)
        }
    }

    /// Handle errors when attempting to log in with an email address
    ///
    func handleLoginError(_ error: Error) {
        let userInfo = (error as NSError).userInfo
        let errorCode = userInfo[WordPressComRestApi.ErrorKeyErrorCode] as? String

        if configuration.enableSignUp, errorCode == "unknown_user" {
            self.sendEmail()
        } else if errorCode == "email_login_not_allowed" {
                // If we get this error, we know we have a WordPress.com user but their
                // email address is flagged as suspicious.  They need to login via their
                // username instead.
                self.showSelfHostedWithError(error)
        } else {
            let signInError = SignInError(error: error, source: source) ?? error
            guard let authenticationDelegate = WordPressAuthenticator.shared.delegate,
                  authenticationDelegate.shouldHandleError(signInError) else {
                displayError(error as NSError, sourceTag: sourceTag)
                return
            }

            /// Hand over control to the host app.
            authenticationDelegate.handleError(signInError) { customUI in
                // Setting the rightBarButtonItems of the custom UI before pushing the view controller
                // and resetting the navigationController's navigationItem after the push seems to be the
                // only combination that gets the Help button to show up.
                customUI.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems
                self.navigationController?.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems

                self.navigationController?.pushViewController(customUI, animated: true)
            }
        }
    }

    // MARK: - Send email

    /// Makes the call to request a magic signup link be emailed to the user.
    ///
    private func sendEmail() {
        tracker.set(flow: .signup)
        loginFields.meta.emailMagicLinkSource = .signup

        configureSubmitButton(animating: true)

        let service = WordPressComAccountService()
        service.requestSignupLink(for: loginFields.username,
                                  success: { [weak self] in
                                    self?.didRequestSignupLink()
                                    self?.configureSubmitButton(animating: false)

            }, failure: { [weak self] (error: Error) in
                DDLogError("Request for signup link email failed.")

                guard let self = self else {
                    return
                }

                self.tracker.track(failure: error.localizedDescription)
                self.displayError(error as NSError, sourceTag: self.sourceTag)
                self.configureSubmitButton(animating: false)
        })
    }

    private func didRequestSignupLink() {
        guard let vc = SignupMagicLinkViewController.instantiate(from: .unifiedSignup) else {
            DDLogError("Failed to navigate from UnifiedSignupViewController to SignupMagicLinkViewController")
            return
        }

        vc.loginFields = loginFields
        vc.loginFields.restrictToWPCom = true

        navigationController?.pushViewController(vc, animated: true)
    }

    /// Makes the call to request a magic authentication link be emailed to the user.
    ///
    func requestAuthenticationLink() {
        loginFields.meta.emailMagicLinkSource = .login

        let email = loginFields.username
        guard email.isValidEmail() else {
            present(buildInvalidEmailLinkAlert(), animated: true, completion: nil)
            return
        }

        configureViewLoading(true)
        let service = WordPressComAccountService()
        service.requestAuthenticationLink(for: email,
                                          jetpackLogin: loginFields.meta.jetpackLogin,
                                          success: { [weak self] in
                                            self?.didRequestAuthenticationLink()
                                            self?.configureViewLoading(false)

            }, failure: { [weak self] (error: Error) in
                guard let self = self else {
                    return
                }

                self.tracker.track(failure: error.localizedDescription)

                self.displayError(error as NSError, sourceTag: self.sourceTag)
                self.configureViewLoading(false)
        })
    }

    /// When a magic link successfully sends, navigate the user to the next step.
    ///
    func didRequestAuthenticationLink() {
        guard let vc = LoginMagicLinkViewController.instantiate(from: .unifiedLoginMagicLink) else {
            DDLogError("Failed to navigate to LoginMagicLinkViewController from GetStartedViewController")
            return
        }

        vc.loginFields = self.loginFields
        vc.loginFields.restrictToWPCom = true
        navigationController?.pushViewController(vc, animated: true)
    }

    /// Build the alert message when the email address is invalid
    ///
    private func buildInvalidEmailAlertGeneric() -> UIAlertController {
        let title = NSLocalizedString("Invalid Email Address",
                                      comment: "Title of an alert letting the user know the email address that they've entered isn't valid")
        let message = NSLocalizedString("Please enter a valid email address for a WordPress.com account.",
                                        comment: "An error message.")

        return buildInvalidEmailAlert(title: title, message: message)
    }

    /// Build the alert message when the email address is invalid so a link cannot be requested
    ///
    private func buildInvalidEmailLinkAlert() -> UIAlertController {
        let title = NSLocalizedString("Can Not Request Link",
                                      comment: "Title of an alert letting the user know")
        let message = NSLocalizedString("A valid email address is needed to mail an authentication link. Please return to the previous screen and provide a valid email address.",
                                        comment: "An error message.")

        return buildInvalidEmailAlert(title: title, message: message)
    }

    private func buildInvalidEmailAlert(title: String, message: String) -> UIAlertController {

        let helpActionTitle = NSLocalizedString("Need help?",
                                                comment: "Takes the user to get help")
        let okActionTitle = NSLocalizedString("OK",
                                              comment: "Dismisses the alert")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addActionWithTitle(helpActionTitle,
                                 style: .cancel,
                                 handler: { _ in
                                    WordPressAuthenticator.shared.delegate?.presentSupportRequest(from: self, sourceTag: .loginEmail)
        })

        alert.addActionWithTitle(okActionTitle, style: .default, handler: nil)

        return alert
    }

    /// When password autofill has entered a password on this screen, attempt to login immediately
    ///
    func attemptAutofillLogin() {
        // Even though there was no explicit submit action by the user, we'll interpret
        // the credentials selection as such.
        tracker.track(click: .submit)

        loginFields.password = hiddenPasswordField?.text ?? ""
        loginFields.meta.socialService = nil
        displayError(message: "")
        validateFormAndLogin()
    }

    /// Configures loginFields to log into wordpress.com and navigates to the selfhosted username/password form.
    /// Displays the specified error message when the new view controller appears.
    ///
    func showSelfHostedWithError(_ error: Error) {
        loginFields.siteAddress = "https://wordpress.com"
        errorToPresent = error

        tracker.track(failure: error.localizedDescription)

        guard let vc = SiteCredentialsViewController.instantiate(from: .siteAddress) else {
            DDLogError("Failed to navigate to SiteCredentialsViewController from GetStartedViewController")
            return
        }

        vc.loginFields = loginFields
        vc.dismissBlock = dismissBlock
        vc.errorToPresent = errorToPresent

        navigationController?.pushViewController(vc, animated: true)
    }

    /// Navigates to site credentials screen where .org site credentials can be entered
    ///
    func goToSiteCredentialsScreen() {
        guard let vc = SiteCredentialsViewController.instantiate(from: .siteAddress) else {
            DDLogError("Failed to navigate from GetStartedViewController to SiteCredentialsViewController")
            return
        }

        vc.loginFields = loginFields.copy()
        vc.dismissBlock = dismissBlock
        vc.errorToPresent = errorToPresent

        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Social Button Management

private extension GetStartedViewController {

    func configureSocialButtons() {
        guard let buttonViewController = buttonViewController else {
            return
        }

        buttonViewController.hideShadowView()

        if configuration.enableSignInWithApple {
            buttonViewController.setupTopButtonFor(socialService: .apple, onTap: appleTapped)
        }

        buttonViewController.setupButtomButtonFor(socialService: .google, onTap: googleTapped)

        let termsButton = WPStyleGuide.signupTermsButton()
        buttonViewController.stackView?.addArrangedSubview(termsButton)
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
    }

    func configureButtonViewControllerForSiteCredentialsMode() {
        guard let buttonViewController = buttonViewController else {
            return
        }

        buttonViewController.hideShadowView()

        // Add a "Continue" button here as the `continueButton` at the top
        // will not be displayed for `signInUsingSiteCredentials` screen mode.
        //
        buttonViewController.setupTopButton(title: ButtonConfiguration.Continue.title,
                                            isPrimary: true,
                                            accessibilityIdentifier: ButtonConfiguration.Continue.accessibilityIdentifier,
                                            onTap: handleSubmitButtonTapped)

        // Setup Sign in with site credentials button
        buttonViewController.setupBottomButton(attributedTitle: WPStyleGuide.formattedSignInWithSiteCredentialsString(),
                                               isPrimary: false,
                                               accessibilityIdentifier: ButtonConfiguration.SignInWithSiteCredentials.accessibilityIdentifier,
                                               onTap: handleSiteCredentialsButtonTapped)
    }

    func configureButtonViewControllerWithoutSocialLogin() {
        guard let buttonViewController = buttonViewController else {
            return
        }

        buttonViewController.hideShadowView()

        // Add a "Continue" button here as the `continueButton` at the top will be hidden
        //
        buttonViewController.setupTopButton(title: ButtonConfiguration.Continue.title,
                                            isPrimary: true,
                                            accessibilityIdentifier: ButtonConfiguration.Continue.accessibilityIdentifier,
                                            onTap: handleSubmitButtonTapped)
    }

    @objc func appleTapped() {
        tracker.track(click: .loginWithApple)

        AppleAuthenticator.sharedInstance.delegate = self
        AppleAuthenticator.sharedInstance.showFrom(viewController: self)
    }

    @objc func googleTapped() {
        tracker.track(click: .loginWithGoogle)

        guard let toVC = GoogleAuthViewController.instantiate(from: .googleAuth) else {
            DDLogError("Failed to navigate to GoogleAuthViewController from GetStartedViewController")
            return
        }

        navigationController?.pushViewController(toVC, animated: true)
    }

    @objc func termsTapped() {
        tracker.track(click: .termsOfService)

        guard let url = URL(string: configuration.wpcomTermsOfServiceURL) else {
            DDLogError("GetStartedViewController: wpcomTermsOfServiceURL unavailable.")
            return
        }

        UIApplication.shared.open(url)
    }
}

// MARK: - XMLRPC checks

private extension GetStartedViewController {
    /// Configures the buttons and navigation item
    ///
    func configureScreenForRunningXMLRPCChecks(loading: Bool) {
        buttonViewController?.setTopButtonState(isLoading: false,
                                                isEnabled: !loading)
        buttonViewController?.setBottomButtonState(isLoading: loading,
                                                   isEnabled: !loading)
        navigationItem.hidesBackButton = loading
    }

    /// Navigates to site credentials screen where .org site credentials can be entered
    ///
    func guessXMLRPCURL(for siteAddress: String) {
        configureScreenForRunningXMLRPCChecks(loading: true)

        let facade = WordPressXMLRPCAPIFacade()
        facade.guessXMLRPCURL(forSite: siteAddress, success: { [weak self] (url) in
            self?.configureScreenForRunningXMLRPCChecks(loading: false)

            if let url = url {
                self?.loginFields.meta.xmlrpcURL = url as NSURL
            }

            self?.goToSiteCredentialsScreen()

            }, failure: { [weak self] (error) in
                guard let error = error, let self = self else {
                    return
                }

                self.tracker.track(failure: error.localizedDescription)

                self.configureScreenForRunningXMLRPCChecks(loading: false)

                let xmlrpcError = XMLRPCError.xmlrpcError(siteAddress: siteAddress)
                /// Check if the host app wants to provide custom UI to handle the error.
                /// If it does, insert the custom UI provided by the host app and exit early
                if self.authenticationDelegate.shouldHandleError(xmlrpcError) {
                    self.authenticationDelegate.handleError(xmlrpcError) { customUI in
                        self.pushCustomUI(customUI)
                    }

                    return
                }

                let err = self.originalErrorOrError(error: error as NSError)

                if let xmlrpcValidatorError = err as? WordPressOrgXMLRPCValidatorError {
                    self.displayErrorAlert(xmlrpcValidatorError.localizedDescription, sourceTag: self.sourceTag)
                } else if (err.domain == NSURLErrorDomain && err.code == NSURLErrorCannotFindHost) ||
                            (err.domain == NSURLErrorDomain && err.code == NSURLErrorNetworkConnectionLost) {
                    // NSURLErrorNetworkConnectionLost can be returned when an invalid URL is entered.
                    let msg = NSLocalizedString(
                        "The site at this address is not a WordPress site. For us to connect to it, the site must use WordPress.",
                        comment: "Error message shown a URL does not point to an existing site.")
                    self.displayErrorAlert(msg, sourceTag: self.sourceTag)

                } else {
                    self.displayError(error as NSError, sourceTag: self.sourceTag)
                }
        })
    }

    func originalErrorOrError(error: NSError) -> NSError {
        guard let err = error.userInfo[XMLRPCOriginalErrorKey] as? NSError else {
            return error
        }
        return err
    }

    /// Push a custom view controller, provided by a host app, to the navigation stack
    func pushCustomUI(_ customUI: UIViewController) {
        /// Assign the help button of the newly injected UI to the same help button we are currently displaying
        /// We are making a somewhat big assumption here: the chrome of the new UI we insert would look like the UI
        /// WPAuthenticator is already displaying. Which is risky, but also kind of makes sense, considering
        /// we are also pushing that injected UI to the current navigation controller.
        if WordPressAuthenticator.shared.delegate?.supportActionEnabled == true {
            customUI.navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems
        }

        navigationController?.pushViewController(customUI, animated: true)
    }
}

// MARK: - SFSafariViewControllerDelegate

extension GetStartedViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // This will only work when the user taps "Done" in the terms of service screen.
        // It won't be executed if the user dismisses the terms of service VC by sliding it out of view.
        // Unfortunately I haven't found a way to track that scenario.
        //
        tracker.track(click: .dismiss)
    }
}

// MARK: - AppleAuthenticatorDelegate

extension GetStartedViewController: AppleAuthenticatorDelegate {

    func showWPComLogin(loginFields: LoginFields) {
        self.loginFields = loginFields
        showPasswordView()
    }

    func showApple2FA(loginFields: LoginFields) {
        self.loginFields = loginFields
        signInAppleAccount()
    }

    func authFailedWithError(message: String) {
        displayErrorAlert(message, sourceTag: .loginApple)
        tracker.set(flow: .wpCom)
    }

}

// MARK: - LoginFacadeDelegate

extension GetStartedViewController {

    // Used by SIWA when logging with with a passwordless, 2FA account.
    //
    func needsMultifactorCode(forUserID userID: Int, andNonceInfo nonceInfo: SocialLogin2FANonceInfo) {
        configureViewLoading(false)
        socialNeedsMultifactorCode(forUserID: userID, andNonceInfo: nonceInfo)
    }

}

// MARK: - UITextFieldDelegate

extension GetStartedViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        tracker.track(click: .selectEmailField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if canSubmit() {
            validateForm()
        }
        return true
    }

}

// MARK: - Keyboard Notifications

extension GetStartedViewController {
    @objc func handleKeyboardWillShow(_ notification: Foundation.Notification) {
        keyboardWillShow(notification)
    }

    @objc func handleKeyboardWillHide(_ notification: Foundation.Notification) {
        keyboardWillHide(notification)
    }
}

// MARK: - Button configuration

private extension GetStartedViewController {
    enum ButtonConfiguration {
        enum Continue {
            static let title = WordPressAuthenticator.shared.displayStrings.continueButtonTitle
            static let accessibilityIdentifier = "Get Started Email Continue Button"
        }

        enum SignInWithSiteCredentials {
            static let accessibilityIdentifier = "Sign in with site credentials Button"
        }
    }
}
