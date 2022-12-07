import ScreenObject
import XCTest

struct GoogleSignInSafariScreen {

    private let app: XCUIApplication
    private let email = APICredentials.Tests.GoogleAccount.email
    private let password = APICredentials.Tests.GoogleAccount.password

    enum Labels {
        static let selectDifferentAccount = "Use another account"
        static let next = "Next"
    }

    init(app: XCUIApplication) {
        self.app = app
    }

    func authenticate(file: StaticString = #file, line: UInt = #line) {
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

        // To make sure the credentials input screen is gone, check none of the input elemets are
        // on screen.
        XCTAssertFalse(app.textFields.firstMatch.exists, file: file, line: line)
        XCTAssertFalse(app.secureTextFields.firstMatch.exists, file: file, line: line)
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
