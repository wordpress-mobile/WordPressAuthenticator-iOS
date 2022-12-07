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

    func testGoogleLoginForUnlinkedAccountShowsSignUpScreen() throws {
        let app = XCUIApplication()
        app.launch()

        try StartScreen(app: app)
            .showLogin()
            .selectContinue()
            .continueWithGoogle()
            .continue(app: app)
            .authenticate()

        XCTAssertTrue(app.staticTexts["Sign Up"].waitForExistence(timeout: 10))
    }

    override func record(_ issue: XCTIssue) {
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())

        let separator = "-"
        let name = issue.description
            .replacing(" ", with: separator)
            .replacing(":", with: separator)
            .replacing("\(separator)\(separator)", with: separator)
            .lowercased()
        // - Add a custom prefix to identify these screenshots from those automatically taken
        // - Need to append an extension for the image to be properly extracted
        screenshot.name = "failure-\(name).png"

        screenshot.lifetime = .keepAlways

        add(screenshot)

        super.record(issue)
    }
}
