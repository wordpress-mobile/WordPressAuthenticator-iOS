import ScreenObject
import XCTest

/// Slimmed down version of the one found in the WordPress iOS codebased.
///
/// Eventually, this should end up in a UI testing helper framework that the package exports, so that consumers can use it to write their
/// own UI tests if they see fit.
///
/// See
/// https://github.com/wordpress-mobile/WordPress-iOS/blob/9f9a7620cf6b9924fe9385c0b98ad4de8dd686bb/WordPress/UITestsFoundation/Screens/Login/Unified/GetStartedScreen.swift
class GetStartedScreen: ScreenObject {

    private let continueWithGoogleButtonGetter: (XCUIApplication) -> XCUIElement = {
        $0.buttons["Continue with Google Button"]
    }

    var continueWithGoogleButton: XCUIElement { continueWithGoogleButtonGetter(app) }

    init(app: XCUIApplication) throws {
        try super.init(expectedElementGetter: continueWithGoogleButtonGetter)
    }

    func continueWithGoogle() throws -> ContinueWithGoogleAlert {
        continueWithGoogleButton.tap()

        return try ContinueWithGoogleAlert()
    }
}
