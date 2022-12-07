import ScreenObject
import XCTest

class StartScreen: ScreenObject {

    convenience init(app: XCUIApplication) throws {
        try self.init(
            expectedElementGetters: [ { $0.staticTexts["Show Login"] } ]
        )
    }

    func showLogin() {
        expectedElement.tap()
    }
}
