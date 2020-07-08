import XCTest
@testable import WordPressAuthenticator

class CredentialsTests: XCTestCase {
    
    let token = "arstdhneio123456789qwfpgjluy"
    let siteURL = "https://example.com"
    
    func testWordpressComCredentialsInit() {
        let wpcomCredentials = WordPressComCredentials(authToken: token,
                                                       isJetpackLogin: false,
                                                       multifactor: false,
                                                       siteURL: siteURL)
        
        XCTAssertEqual(wpcomCredentials.authToken, token)
        XCTAssertEqual(wpcomCredentials.isJetpackLogin, false)
        XCTAssertEqual(wpcomCredentials.multifactor, false)
        XCTAssertEqual(wpcomCredentials.siteURL, siteURL)
    }
    
    func testWordPressComCredentialsSiteURLReturnsDefaultValue() {
        let wpcomCredentials = WordPressComCredentials(authToken: token,
                                                       isJetpackLogin: false,
                                                       multifactor: false,
                                                       siteURL: "")
        
        let expected = "https://wordpress.com"
    
        XCTAssertEqual(wpcomCredentials.siteURL, expected)
    }
    
    func testWordPressCredentialsEquatable() {
        let lhs = WordPressComCredentials(authToken: token,
                                          isJetpackLogin: false,
                                          multifactor: false,
                                          siteURL: siteURL)
        
        let rhs = WordPressComCredentials(authToken: token,
                                          isJetpackLogin: false,
                                          multifactor: false,
                                          siteURL: siteURL)
        
        XCTAssertTrue(lhs == rhs)
    }
    
    func testWordPressCredentialsNotEquatable() {
        let lhs = WordPressComCredentials(authToken: token,
                                          isJetpackLogin: false,
                                          multifactor: false,
                                          siteURL: siteURL)
        
        let rhs = WordPressComCredentials(authToken: token,
                                          isJetpackLogin: false,
                                          multifactor: false,
                                          siteURL: "")
        
        XCTAssertFalse(lhs == rhs)
    }
}
