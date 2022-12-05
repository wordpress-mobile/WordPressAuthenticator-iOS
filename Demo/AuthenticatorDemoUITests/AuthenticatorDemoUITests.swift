import XCTest

class AuthenticatorDemoUITests: XCTestCase {

    let email = APICredentials.Tests.GoogleAccount.email
    let password = APICredentials.Tests.GoogleAccount.password

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testGoogleSingInFlowImmediateCancellation() throws {
        let app = XCUIApplication()
        app.launch()

        app.staticTexts["New Google SignIn"].tap()

        // Usually, one wuold use addUIInterruptionMonitor to handle the alert iOS shows to hand
        // over to the Safari view controller to continue with Google. Unfortunately, that seem
        // to clash with the other alerts prestend during the flow, with the handler being called
        // for them, too, dismissing them, and making the following code that looks for them.
        //
        // Luckily, we can access the "continue with Google" alert via Springboard.
        //
        // Kudos https://stackoverflow.com/a/58171074/809944
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let continueWithGoogleAlert = springboard.alerts.firstMatch
        XCTAssertTrue(continueWithGoogleAlert.waitForExistence(timeout: 5))
        continueWithGoogleAlert.buttons["Cancel"].tap()

        // Currently, cancelling the process shows an error.
        // Use that alert as the verification that the cancellation flow was successful.
        let dismissAlertButton = app.buttons["Dismiss"]
        XCTAssertTrue(dismissAlertButton.waitForExistence(timeout: 5))
        // Ensure what we're seeing is actually the error alert
        XCTAssertTrue(app.staticTexts["❌"].exists)
        dismissAlertButton.tap()
    }

    func testGoogleSignInFlowSelectAlredyLoggedInUser() throws {
        let app = XCUIApplication()
        app.launch()

        app.staticTexts["New Google SignIn"].tap()

        // Usually, one wuold use addUIInterruptionMonitor to handle the alert iOS shows to hand
        // over to the Safari view controller to continue with Google. Unfortunately, that seem
        // to clash with the other alerts prestend during the flow, with the handler being called
        // for them, too, dismissing them, and making the following code that looks for them.
        //
        // Luckily, we can access the "continue with Google" alert via Springboard.
        //
        // Kudos https://stackoverflow.com/a/58171074/809944
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let continueWithGoogleAlert = springboard.alerts.firstMatch
        XCTAssertTrue(continueWithGoogleAlert.waitForExistence(timeout: 5))
        continueWithGoogleAlert.buttons["Continue"].tap()

        GoogleSignInScreen(app: app).authenticate()

        XCTAssertTrue(app.alerts["🎉"].waitForExistence(timeout: 30))
        app.buttons["Dismiss"].tap()
    }
}

struct GoogleSignInScreen {

    private let app: XCUIApplication
    private let email = APICredentials.Tests.GoogleAccount.email
    private let password = APICredentials.Tests.GoogleAccount.password

    enum Labels {
        static let selectDifferentAccount = "Utilizza un altro account"
        static let next = "Avanti"
    }

    init(app: XCUIApplication) {
        self.app = app
    }

    func authenticate() {
        // The device in which we're running the tests might have pre-existing accounts available.
        let emailField = app.staticTexts[email]
        let selectDifferentAccount = app.staticTexts[Labels.selectDifferentAccount]
        if emailField.waitForExistence(timeout: 5) {
            emailField.tap()
        } else {
            if selectDifferentAccount.waitForExistence(timeout: 5) {
                selectDifferentAccount.tap()
            }
            typeEmail()
            typePassword()
        }
    }

    private func typeEmail() {
        app.textFields.firstMatch.typeText(email)
        continueFromKeyboardOrScreen()
    }

    private func typePassword() {
        app.secureTextFields.firstMatch.typeText(password)
        continueFromKeyboardOrScreen()
    }

    private func continueFromKeyboardOrScreen() {
        // If the keyboard is on screen, trying to tap a button in the screen that is underneath it
        // will result in the keyboard being pressed instead...
        guard let keyboardContinueButton else {
            app.buttons[Labels.next].tap()
            return
        }

        keyboardContinueButton.tap()
    }

    var keyboardContinueButton: XCUIElement? {
        let keyboardReturnButton = app.keyboards.firstMatch.buttons["Return"]
        if keyboardReturnButton.exists {
            return keyboardReturnButton
        }

        let keyboardGoButton = app.keyboards.firstMatch.buttons["Go"]
        if keyboardGoButton.exists {
            return keyboardGoButton
        }

        return .none
    }
}
