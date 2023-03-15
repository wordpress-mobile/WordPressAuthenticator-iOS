import ScreenObject
import XCTest

struct GoogleSignInSafariScreen {

    private let app: XCUIApplication
    private let email = APICredentials.Tests.GoogleAccount.email
    private let password = APICredentials.Tests.GoogleAccount.password

    enum Labels {
        // This screen object is an interface with the Safari modal screen presented by the
        // authentication process. This means the elements we interact with are from a web page
        // and don't have any accessibility identifier that we can control to decouple the
        // selectors from any given locale.
        //
        // English is used here as the standard language for testing. Depending on where you are
        // located when running these tests locally, you might have to update the values in your
        // locale, or VPN to an English speaking country.
        static let selectDifferentAccount = "Use another account"
        static let next = "Next"
    }

    init(app: XCUIApplication) {
        self.app = app
    }

    func authenticate(file: StaticString = #file, line: UInt = #line) {
        let existingAccountEntry = app.staticTexts[email]
        let selectDifferentAccount = app.staticTexts[Labels.selectDifferentAccount]

        // The device in which we're running the tests might have pre-existing accounts available.
        // If there is one, we'll need to select it.
        if existingAccountEntry.waitForExistence(timeout: 5) {
            existingAccountEntry.tap()
        } else {
            if selectDifferentAccount.waitForExistence(timeout: 5) {
                selectDifferentAccount.tap()
            }
            typeEmail()
            typePassword()
        }

        // To make sure the credentials input screen is gone, check none of the input elements are
        // on screen.
        XCTAssertFalse(app.textFields.firstMatch.exists, file: file, line: line)
        XCTAssertFalse(app.secureTextFields.firstMatch.exists, file: file, line: line)
    }

    private func typeEmail() {
        let emailInput = app.textFields.firstMatch
        // Depending on whether the Simulator has the software keyboard enabled or not, we might
        // need to tap the text field before being able to type on it. Luckily, tapping when it's
        // not neccessary doesn't affect the typing behavior.
        emailInput.tap()
        emailInput.typeText(email)
        continueFromKeyboardOrScreen()
    }

    private func typePassword() {
        let passwordInput = app.secureTextFields.firstMatch
        // Depending on whether the Simulator has the software keyboard enabled or not, we might
        // need to tap the secure text field before being able to type on it. Luckily, tapping when
        // it's not neccessary doesn't affect the typing behavior.
        passwordInput.tap()
        passwordInput.firstMatch.typeText(password)
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
