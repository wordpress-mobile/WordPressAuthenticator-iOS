import ScreenObject
import XCTest

/// Slimmed down version of the one found in the WordPress iOS codebased.
///
/// Eventually, this should end up in a UI testing helper framework that the package exports, so that consumers can use it to write their
/// own UI tests if they see fit.
///
/// See
/// https://github.com/wordpress-mobile/WordPress-iOS/blob/9f9a7620cf6b9924fe9385c0b98ad4de8dd686bb/WordPress/UITestsFoundation/Screens/Login/Unified/PrologueScreen.swift
class PrologueScreen: ScreenObject {

    private let continueButtonGetter: (XCUIApplication) -> XCUIElement = {
        $0.buttons["Prologue Continue Button"]
    }

    private let enterSiteAddressButtonGetter: (XCUIApplication) -> XCUIElement = {
        $0.buttons["Prologue Self Hosted Button"]
    }

    var continueButton: XCUIElement { continueButtonGetter(app) }
    var siteAddressButton: XCUIElement { enterSiteAddressButtonGetter(app) }

    init(app: XCUIApplication) throws {
        try super.init(
            expectedElementGetters: [continueButtonGetter, enterSiteAddressButtonGetter],
            app: app,
            waitTimeout: 3
        )
    }

    func selectContinue() throws -> GetStartedScreen {
        continueButton.tap()

        return try GetStartedScreen(app: app)
    }
}
