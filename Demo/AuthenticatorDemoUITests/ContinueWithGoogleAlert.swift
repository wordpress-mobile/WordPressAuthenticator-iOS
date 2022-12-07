import ScreenObject
import XCTest

class ContinueWithGoogleAlert: ScreenObject {

    private let alertGetter: (XCUIApplication) -> XCUIElement = {
        // There might be a more precise way to get the alert, such as looking at this label
        $0.alerts.firstMatch
    }

    private var cancelButton: XCUIElement { alertGetter(app).buttons["Cancel"] }
    private var continueButton: XCUIElement { alertGetter(app).buttons["Continue"] }

    init() throws {
        // Usually, one wuold use addUIInterruptionMonitor to handle the alert iOS shows to hand
        // over to the Safari view controller to continue with Google.
        // Unfortunately, that seems to clash with the other alerts prestend during the flow,
        // with the handler being called for them, too, dismissing them, and making the following
        // code that looks for them.
        //
        // Luckily, we can access the "Continue with Google" alert via Springboard, which seems to
        // end up being a more robust approach anyway.
        //
        // Kudos https://stackoverflow.com/a/58171074/809944
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        try super.init(expectedElementGetter: alertGetter, app: springboard)
    }

    func cancel() {
        cancelButton.tap()
    }

    func `continue`(app: XCUIApplication) -> GoogleSignInSafariScreen {
        continueButton.tap()

        return GoogleSignInSafariScreen(app: app)
    }
}

struct GoogleSignInSafariScreen {

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
