@testable import WordPressAuthenticator
import XCTest

// The logic depends, in part, on iOS 16 features.
// We could test for the earlier versions but that would optimizing for a small minority and not worth at this point in time.
@available(iOS 16, *)
class TwoFAViewControllerTests: XCTestCase {

    func testLoadRowsWithNoErrorAndNoPasskeys() {
        let defualtRows: [TwoFAViewController.Row] = [.instructions, .code, .alternateInstructions, .sendCode]

        XCTAssertEqual(
            TwoFAViewController.computeRows(errorMessage: nil, nonceWebauthn: nil, passkeysEnabled: false),
            defualtRows
        )
        XCTAssertEqual(
            TwoFAViewController.computeRows(errorMessage: nil, nonceWebauthn: nil, passkeysEnabled: true),
            defualtRows
        )
        XCTAssertEqual(
            TwoFAViewController.computeRows(errorMessage: nil, nonceWebauthn: "some error", passkeysEnabled: false),
            defualtRows
        )
    }

    func testLoadRowsWithErrorAndNoPasskeys() {
        let expectedRows: [TwoFAViewController.Row] = [.instructions, .code, .errorMessage, .alternateInstructions, .sendCode]

        XCTAssertEqual(
            TwoFAViewController.computeRows(errorMessage: "some error", nonceWebauthn: nil, passkeysEnabled: false),
            expectedRows
        )
        XCTAssertEqual(
            TwoFAViewController.computeRows(errorMessage: "some error", nonceWebauthn: nil, passkeysEnabled: true),
            expectedRows
        )
        XCTAssertEqual(
            TwoFAViewController.computeRows(errorMessage: "some error", nonceWebauthn: "some nonce", passkeysEnabled: false),
            expectedRows
        )
    }

    func testLoadRowsWithNoErrorButPasskeys() {
        XCTAssertEqual(
            TwoFAViewController.computeRows(errorMessage: "some error", nonceWebauthn: "some nonce", passkeysEnabled: true),
            [.instructions, .code, .errorMessage, .alternateInstructions, .sendCode, .enterSecurityKey]
        )
    }

    func testLoadRowsWithErrorAndPasskeys() {
        XCTAssertEqual(
            TwoFAViewController.computeRows(errorMessage: "some error", nonceWebauthn: "some nonce", passkeysEnabled: true),
            [.instructions, .code, .errorMessage, .alternateInstructions, .sendCode, .enterSecurityKey]
        )
    }
}
