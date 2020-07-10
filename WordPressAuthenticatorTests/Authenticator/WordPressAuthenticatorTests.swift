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
//        WordPressAuthenticator.initialize(configuration: MockWordpressAuthenticatorProvider.wordPressAuthenticatorConfiguration(), style: MockWordpressAuthenticatorProvider.wordPressAuthenticatorStyle(), unifiedStyle: nil)
        let authenticator = WordPressAuthenticator.shared
        
        XCTAssertEqual(authenticator.configuration.wpcomClientId, "23456")
        XCTAssertEqual(authenticator.style.primaryNormalBackgroundColor, UIColor.black)
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
    
    static func wordPressAuthenticatorStyle() -> WordPressAuthenticatorStyle {
        return WordPressAuthenticatorStyle(primaryNormalBackgroundColor: UIColor.black,
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
                                           navBarBackgroundColor: UIColor.black
        )
    }
}
