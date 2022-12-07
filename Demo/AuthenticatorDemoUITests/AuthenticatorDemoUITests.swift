import XCTest

final class AuthenticatorDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCancellingContinueWithGooglePromptReturnsToGetStartedScreen() throws {
        let app = XCUIApplication()
        app.launch()

        try StartScreen(app: app)
            .showLogin()
            .selectContinue()
            .continueWithGoogle()
            .cancel()

        XCTAssertTrue(try GetStartedScreen(app: app).isLoaded)
    }
}
