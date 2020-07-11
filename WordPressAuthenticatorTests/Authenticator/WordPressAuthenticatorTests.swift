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
    
    func testSignInForWPOrgReturnsVC() {
        let vc = WordPressAuthenticator.signinForWPOrg()
        
        XCTAssertTrue((vc as Any) is LoginSiteAddressViewController)
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
}

struct MockWordpressAuthenticatorProvider {
    static func wordPressAuthenticatorConfiguration() -> WordPressAuthenticatorConfiguration {
        return WordPressAuthenticatorConfiguration(wpcomClientId: "23456",
                                                   wpcomSecret: "arfv35dj57l3g2323",
                                                   wpcomScheme: "https://",
                                                   wpcomTermsOfServiceURL: "https://wordpress.com/tos/",
                                                   googleLoginClientId: "",
                                                   googleLoginServerClientId: "",
                                                   googleLoginScheme: "",
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
