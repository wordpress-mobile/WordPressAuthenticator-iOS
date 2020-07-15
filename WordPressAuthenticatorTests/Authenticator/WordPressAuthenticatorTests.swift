import XCTest
@testable import WordPressAuthenticator
// MARK: - WordPressAuthenticator Unit Tests
//
class WordPressAuthenticatorTests: XCTestCase {
    
    let timeInterval = TimeInterval(3)
    
    override class func setUp() {
        super.setUp()
        
        WordPressAuthenticator.initialize(configuration: MockWordpressAuthenticatorProvider.wordPressAuthenticatorConfiguration(), style: MockWordpressAuthenticatorProvider.wordPressAuthenticatorStyle(.random), unifiedStyle: nil)
        
    }
    
    func testBaseSiteURL() {
        var baseURL = "testsite.wordpress.com"
        var url = WordPressAuthenticator.baseSiteURL(string: "http://\(baseURL)")
        XCTAssert(url == "https://\(baseURL)", "Should force https for a wpcom site having http.")
        
        url = WordPressAuthenticator.baseSiteURL(string: baseURL)
        XCTAssert(url == "https://\(baseURL)", "Should force https for a wpcom site without a scheme.")
        
        baseURL = "www.selfhostedsite.com"
        url = WordPressAuthenticator.baseSiteURL(string: baseURL)
        XCTAssert((url == "https://\(baseURL)"), "Should add https:\\ for a non wpcom site missing a scheme.")
        
        url = WordPressAuthenticator.baseSiteURL(string: "\(baseURL)/wp-login.php")
        XCTAssert((url == "https://\(baseURL)"), "Should remove wp-login.php from the path.")
        
        url = WordPressAuthenticator.baseSiteURL(string: "\(baseURL)/wp-admin")
        XCTAssert((url == "https://\(baseURL)"), "Should remove /wp-admin from the path.")
        
        url = WordPressAuthenticator.baseSiteURL(string: "\(baseURL)/wp-admin/")
        XCTAssert((url == "https://\(baseURL)"), "Should remove /wp-admin/ from the path.")
        
        url = WordPressAuthenticator.baseSiteURL(string: "\(baseURL)/")
        XCTAssert((url == "https://\(baseURL)"), "Should remove a trailing slash from the url.")
        
        // Check non-latin characters and puny code
        baseURL = "http://例.例"
        let punycode = "http://xn--fsq.xn--fsq"
        url = WordPressAuthenticator.baseSiteURL(string: baseURL)
        XCTAssert(url == punycode)
        url = WordPressAuthenticator.baseSiteURL(string: punycode)
        XCTAssert(url == punycode)
    }
    
    func testEmailAddressTokenHandling() {
        let email = "example@email.com"
        let loginFields = LoginFields()
        loginFields.username = email
        WordPressAuthenticator.storeLoginInfoForTokenAuth(loginFields)
        
        var retrievedLoginFields = WordPressAuthenticator.retrieveLoginInfoForTokenAuth()
        var retrievedEmail = retrievedLoginFields.username
        XCTAssert(email == retrievedEmail, "The email retrived should match the email that was saved.")
        
        WordPressAuthenticator.deleteLoginInfoForTokenAuth()
        retrievedLoginFields = WordPressAuthenticator.retrieveLoginInfoForTokenAuth()
        retrievedEmail = retrievedLoginFields.username
        
        XCTAssert(email != retrievedEmail, "Saved loginFields should be deleted after calling deleteLoginInfoForTokenAuth.")
    }
    
    func testAuthenticatorInitHasCorrectProperties() {
        //COME BACK TO THIS
        let authenticator = WordPressAuthenticator.shared
        
        XCTAssertEqual(authenticator.configuration.wpcomClientId, "23456")
    }
    
    func testPushNotificationReceived() {
        let _ = expectation(forNotification: .wordpressSupportNotificationReceived, object: nil, handler: nil)
        
        WordPressAuthenticator.shared.supportPushNotificationReceived()
        
        waitForExpectations(timeout: timeInterval, handler: nil)
        
    }
    
    func testPushNotificationCleared() {
        let _ = expectation(forNotification: .wordpressSupportNotificationCleared, object: nil, handler: nil)
        
        WordPressAuthenticator.shared.supportPushNotificationCleared()
        
        waitForExpectations(timeout: timeInterval, handler: nil)
    }
    
    func testWordpressAuthIsAuthenticationViewController() {
        let loginViewcontroller = LoginViewController()
        let nuxViewController = NUXViewController()
        
        XCTAssertTrue(WordPressAuthenticator.isAuthenticationViewController(loginViewcontroller))
        XCTAssertTrue(WordPressAuthenticator.isAuthenticationViewController(nuxViewController))
    }
    
    func testIsGoogleAuthURL() {
        let url = URL(string: "https://google.com")!
        
        XCTAssertTrue(WordPressAuthenticator.shared.isGoogleAuthUrl(url))
    }
    
    func testIsWordPressAuthURL() {
        let url = URL(string: "https://magic-login")!
        
        XCTAssertTrue(WordPressAuthenticator.shared.isWordPressAuthUrl(url))
    }
    
    func testHandleWordPressAuthURLReturnsTrueOnSucceed() {
        let url = URL(string: "https://wordpress.com/wp-login.php?token=1234567890%26action&magic-login&sr=1&signature=1234567890oienhdtsra")
        
        XCTAssertTrue(WordPressAuthenticator.shared.handleWordPressAuthUrl(url!, allowWordPressComAuth: true, rootViewController: UIViewController()))
    }
    
    func testSignInForWPOrgReturnsVC() {
        let vc = WordPressAuthenticator.signinForWPOrg()
        
        XCTAssertTrue((vc as Any) is LoginSiteAddressViewController)
    }
    
    func testShowLoginFromPresenterReturnsLoginInitialVC() {
        let presenterSpy = ModalViewControllerPresentingSpy()
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { (_, _) -> Bool in
            return presenterSpy.presentedVC != nil
        }), object: .none)
        
        WordPressAuthenticator.showLoginFromPresenter(presenterSpy, animated: true)
        wait(for: [expectation], timeout: 3)
        
        XCTAssertTrue(presenterSpy.presentedVC is LoginNavigationController)
    }
    
    func testShowLoginForJustWPComPresentsCorrectVC() {
        let presenterSpy = ModalViewControllerPresentingSpy()
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { (_, _) -> Bool in
            return presenterSpy.presentedVC != nil
        }), object: .none)
        
        WordPressAuthenticator.showLoginForJustWPCom(from: presenterSpy)
        wait(for: [expectation], timeout: 3)
        
        XCTAssertTrue(presenterSpy.presentedVC is LoginNavigationController)
    }
    
    func testShowLoginForJustWPComTracksOpenedLogin() {
        let presenterSpy = ModalViewControllerPresentingSpy()
        let delegateSpy = WordPressAuthenticatorDelegateSpy()
        WordPressAuthenticator.shared.delegate = delegateSpy
        
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { (_, _) -> Bool in
            return presenterSpy.presentedVC != nil
        }), object: .none)
        
        WordPressAuthenticator.showLoginForJustWPCom(from: presenterSpy)
        wait(for: [expectation], timeout: 3)
        
        let trackedEvent = delegateSpy.trackedElement
        
        XCTAssertEqual(trackedEvent, WPAnalyticsStat.openedLogin)
    }
    
    func testShowLoginForJustWPComSetsMetaProperties() {
        let presenterSpy = ModalViewControllerPresentingSpy()
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { (_, _) -> Bool in
            return presenterSpy.presentedVC != nil
        }), object: .none)
        
        WordPressAuthenticator.showLoginForJustWPCom(from: presenterSpy,
                                                     xmlrpc: "https://example.com/xmlrpc.php",
                                                     username: "username",
                                                     connectedEmail: "email-address@example.com")
        
        guard let navController = presenterSpy.presentedVC as? LoginNavigationController, let controller = navController.viewControllers.first as? LoginEmailViewController else {
            XCTFail("Could not fetch correct ViewController")
            return
        }
        
        wait(for: [expectation], timeout: 3)
        
        XCTAssertEqual(controller.loginFields.restrictToWPCom, true)
        XCTAssertEqual(controller.loginFields.meta.jetpackBlogXMLRPC, "https://example.com/xmlrpc.php")
        XCTAssertEqual(controller.loginFields.meta.jetpackBlogUsername, "username")
        XCTAssertEqual(controller.loginFields.username, "email-address@example.com")
    }
    
    func testShowLoginForSelfHostedSitePresentsCorrectVC() {
        let presenterSpy = ModalViewControllerPresentingSpy()
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { (_, _) -> Bool in
            return presenterSpy.presentedVC != nil
        }), object: .none)
        
        WordPressAuthenticator.showLoginForSelfHostedSite(presenterSpy)
        wait(for: [expectation], timeout: 3)
        
        XCTAssertTrue(presenterSpy.presentedVC is LoginNavigationController)
    }
    
    func testShowLoginForSelfHostedSiteTracksOpenLogin() {
        let presenterSpy = ModalViewControllerPresentingSpy()
        let delegateSpy = WordPressAuthenticatorDelegateSpy()
        
        WordPressAuthenticator.shared.delegate = delegateSpy
        
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { (_, _) -> Bool in
            return presenterSpy.presentedVC != nil
        }), object: .none)
        
        WordPressAuthenticator.showLoginForSelfHostedSite(presenterSpy)
        wait(for: [expectation], timeout: 3)
        
        let trackedEvent = delegateSpy.trackedElement
        
        XCTAssertEqual(trackedEvent, WPAnalyticsStat.openedLogin)
    }
    
    func testSignInForWPComReturnsVC() {
        let vc = WordPressAuthenticator.signinForWPCom()
        
        XCTAssertTrue((vc as Any) is LoginEmailViewController)
    }
    
    func testSignInForWPComWithLoginFieldsReturnsVC() {
        let navController = WordPressAuthenticator.signinForWPCom(dotcomEmailAddress: "example@email.com", dotcomUsername: "username") as! UINavigationController
        let vc = navController.topViewController
        
        XCTAssertTrue((navController as Any) is UIViewController)
        XCTAssertTrue((vc as Any) is LoginWPComViewController)
    }
    
    func testSignInForWPComSetsEmptyLoginFields() {
        let navController = WordPressAuthenticator.signinForWPCom(dotcomEmailAddress: nil, dotcomUsername: nil) as! UINavigationController
        let vc = navController.topViewController as! LoginWPComViewController
        
        XCTAssertEqual(vc.loginFields.emailAddress, String())
        XCTAssertEqual(vc.loginFields.username, String())
    }
    
    func testTrackOpenedLoginSendsCorrectTrackValue() {
        let delegate = WordPressAuthenticatorDelegateSpy()
        WordPressAuthenticator.shared.delegate = delegate
        
        WordPressAuthenticator.trackOpenedLogin()
        
        guard let trackedEvent = delegate.trackedElement else {
            XCTFail("Event not Tracked")
            return
        }
        
        XCTAssertEqual(trackedEvent, WPAnalyticsStat.openedLogin)
    }
    
    func testOpenAuthenticationFailsWithoutQuery() {
        let url = URL(string: "https://WordPress.com/")
        
        let result = WordPressAuthenticator.openAuthenticationURL(url!, allowWordPressComAuth: false, fromRootViewController: UIViewController())
        
        XCTAssertFalse(result)
    }
    
    func testOpenAuthenticationFailsWithoutWpcomAuth() {
        let url = URL(string: "https://WordPress.com/?token=arstdhneio0987654321")
        let loginFields = LoginFields()
        loginFields.username = "user123"
        loginFields.password = "knockknock"
        
        let result = WordPressAuthenticator.openAuthenticationURL(url!, allowWordPressComAuth: false, fromRootViewController: UIViewController())
        
        XCTAssertFalse(result)
    }
    
    func testOpenAuthenticationTracksSignupMagicLink() {
        let url = URL(string: "https://WordPress.com/?token=arstdhneio0987654321")
        let loginFields = LoginFields()
        loginFields.username = "user123"
        loginFields.password = "knockknock"
        loginFields.meta.jetpackBlogXMLRPC = "https://example.com/xmlrpc.php"
        loginFields.meta.jetpackBlogUsername = "jetpack-user"
        loginFields.meta.emailMagicLinkSource = .signup
        WordPressAuthenticator.storeLoginInfoForTokenAuth(loginFields)
        let delegate = WordPressAuthenticatorDelegateSpy()
        WordPressAuthenticator.shared.delegate = delegate
        
        let result = WordPressAuthenticator.openAuthenticationURL(url!, allowWordPressComAuth: true, fromRootViewController: UIViewController())
        guard let trackedEvent = delegate.trackedElement else {
            XCTFail("Event not Tracked")
            return
        }
        
        XCTAssertTrue(result)
        XCTAssertEqual(trackedEvent, WPAnalyticsStat.signupMagicLinkOpened)
    }
    
    func testOpenAuthenticationTracksLoginMagicLinkOpened() {
        let url = URL(string: "https://WordPress.com/?token=arstdhneio0987654321")
        let loginFields = LoginFields()
        loginFields.username = "user123"
        loginFields.password = "knockknock"
        loginFields.meta.jetpackBlogXMLRPC = "https://example.com/xmlrpc.php"
        loginFields.meta.jetpackBlogUsername = "jetpack-user"
        loginFields.meta.emailMagicLinkSource = .login
        WordPressAuthenticator.storeLoginInfoForTokenAuth(loginFields)
        let delegate = WordPressAuthenticatorDelegateSpy()
        WordPressAuthenticator.shared.delegate = delegate
        
        let result = WordPressAuthenticator.openAuthenticationURL(url!, allowWordPressComAuth: true, fromRootViewController: UIViewController())
        guard let trackedEvent = delegate.trackedElement else {
            XCTFail("Event not Tracked")
            return
        }
        
        XCTAssertTrue(result)
        XCTAssertEqual(trackedEvent, WPAnalyticsStat.loginMagicLinkOpened)
    }
}

struct MockWordpressAuthenticatorProvider {
    static func wordPressAuthenticatorConfiguration() -> WordPressAuthenticatorConfiguration {
        return WordPressAuthenticatorConfiguration(wpcomClientId: "23456",
                                                   wpcomSecret: "arfv35dj57l3g2323",
                                                   wpcomScheme: "https",
                                                   wpcomTermsOfServiceURL: "https://wordpress.com/tos/",
                                                   googleLoginClientId: "",
                                                   googleLoginServerClientId: "",
                                                   googleLoginScheme: "https",
                                                   userAgent: "")
    }
    
    static func wordPressAuthenticatorStyle(_ style: AuthenticatorStyeType) -> WordPressAuthenticatorStyle {
        var wpAuthStyle: WordPressAuthenticatorStyle!
        
        switch style {
        case .random:
            wpAuthStyle = WordPressAuthenticatorStyle(primaryNormalBackgroundColor: UIColor.random(),
                                                      primaryNormalBorderColor: UIColor.random(),
                                                      primaryHighlightBackgroundColor: UIColor.random(),
                                                      primaryHighlightBorderColor: UIColor.random(),
                                                      secondaryNormalBackgroundColor: UIColor.random(),
                                                      secondaryNormalBorderColor: UIColor.random(),
                                                      secondaryHighlightBackgroundColor: UIColor.random(),
                                                      secondaryHighlightBorderColor: UIColor.random(),
                                                      disabledBackgroundColor: UIColor.random(),
                                                      disabledBorderColor: UIColor.random(),
                                                      primaryTitleColor: UIColor.random(),
                                                      secondaryTitleColor: UIColor.random(),
                                                      disabledTitleColor: UIColor.random(),
                                                      textButtonColor: UIColor.random(),
                                                      textButtonHighlightColor: UIColor.random(),
                                                      instructionColor: UIColor.random(),
                                                      subheadlineColor: UIColor.random(),
                                                      placeholderColor: UIColor.random(),
                                                      viewControllerBackgroundColor: UIColor.random(),
                                                      textFieldBackgroundColor: UIColor.random(),
                                                      navBarImage: UIImage(color: UIColor.random()),
                                                      navBarBadgeColor: UIColor.random(),
                                                      navBarBackgroundColor: UIColor.random())
        case .wordpressStandard:
            wpAuthStyle = WordPressAuthenticatorStyle(primaryNormalBackgroundColor: UIColor.black,
                                                      primaryNormalBorderColor: UIColor.black,
                                                      primaryHighlightBackgroundColor: UIColor.black,
                                                      primaryHighlightBorderColor: UIColor.black,
                                                      secondaryNormalBackgroundColor: UIColor.black,
                                                      secondaryNormalBorderColor: UIColor.black,
                                                      secondaryHighlightBackgroundColor: UIColor.black,
                                                      secondaryHighlightBorderColor: UIColor.black,
                                                      disabledBackgroundColor: UIColor.black,
                                                      disabledBorderColor: UIColor.black,
                                                      primaryTitleColor: UIColor.black,
                                                      secondaryTitleColor: UIColor.black,
                                                      disabledTitleColor: UIColor.black,
                                                      textButtonColor: UIColor.black,
                                                      textButtonHighlightColor: UIColor.black,
                                                      instructionColor: UIColor.black,
                                                      subheadlineColor: UIColor.black,
                                                      placeholderColor: UIColor.black,
                                                      viewControllerBackgroundColor: UIColor.black,
                                                      textFieldBackgroundColor: UIColor.black,
                                                      navBarImage: UIImage(color: UIColor.black),
                                                      navBarBadgeColor: UIColor.black,
                                                      navBarBackgroundColor: UIColor.black)
        }
        return wpAuthStyle
    }
}

enum AuthenticatorStyeType {
    case random
    case wordpressStandard
}


extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}

class WordPressAuthenticatorDelegateSpy: WordPressAuthenticatorDelegate {
    var dismissActionEnabled: Bool
    
    var supportActionEnabled: Bool
    
    var showSupportNotificationIndicator: Bool
    
    var supportEnabled: Bool
    
    var allowWPComLogin: Bool
    
    var trackedElement: WPAnalyticsStat?
    
    init() {
        self.dismissActionEnabled = false
        self.supportActionEnabled = false
        self.showSupportNotificationIndicator = false
        self.supportEnabled = false
        self.allowWPComLogin = false
        self.trackedElement = nil
    }
    
    func createdWordPressComAccount(username: String, authToken: String) {
        //Implement later
    }
    
    func userAuthenticatedWithAppleUserID(_ appleUserID: String) {
        //Implement Later
    }
    
    func presentSupportRequest(from sourceViewController: UIViewController, sourceTag: WordPressSupportSourceTag) {
        //Implement Later
    }
    
    func shouldPresentUsernamePasswordController(for siteInfo: WordPressComSiteInfo?, onCompletion: @escaping (Error?, Bool) -> Void) {
        //Implement Later
    }
    
    func presentLoginEpilogue(in navigationController: UINavigationController, for credentials: AuthenticatorCredentials, onDismiss: @escaping () -> Void) {
        //Implement Later
    }
    
    func presentSignupEpilogue(in navigationController: UINavigationController, for credentials: AuthenticatorCredentials, service: SocialService?) {
        //Implement Later
    }
    
    func presentSupport(from sourceViewController: UIViewController, sourceTag: WordPressSupportSourceTag) {
        //Implement Later
    }
    
    func shouldPresentLoginEpilogue(isJetpackLogin: Bool) -> Bool {
        //Implement Later
        return isJetpackLogin
    }
    
    func shouldPresentSignupEpilogue() -> Bool {
        //Implement Later
        return false
    }
    
    func sync(credentials: AuthenticatorCredentials, onCompletion: @escaping () -> Void) {
        //Implement Later
    }
    
    func track(event: WPAnalyticsStat) {
        trackedElement = event
    }
    
    func track(event: WPAnalyticsStat, properties: [AnyHashable : Any]) {
        //Implement Later
    }
    
    func track(event: WPAnalyticsStat, error: Error) {
        //Implement Later
    }
    
    
}

protocol ModalViewControllerPresenting {
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
}

extension UIViewController: ModalViewControllerPresenting {}

class ModalViewControllerPresentingSpy: UIViewController {
    internal var presentedVC: UIViewController? = .none
    override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presentedVC = viewControllerToPresent
    }
}

//func presentWithConfigs(from vc: ModalViewControllerPresenting) {
//    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//        let toPresent = TVC(nibName: nil, bundle: nil)
//        toPresent.view.backgroundColor = .blue
//        vc.present(toPresent, animated: true, completion: .none)
//    }
//}
//
//class TVC: UIViewController {}
