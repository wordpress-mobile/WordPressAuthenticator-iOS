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
        // Usually, one would use addUIInterruptionMonitor to handle the alert iOS shows to hand
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
