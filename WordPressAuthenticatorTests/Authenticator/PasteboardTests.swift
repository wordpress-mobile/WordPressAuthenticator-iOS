import XCTest

class PasteboardTests: XCTestCase {
    let timeout = TimeInterval(3)

    override class func tearDown() {
        super.tearDown()
        let pasteboard = UIPasteboard.general
        pasteboard.string = ""
    }

    func testNominalAuthCode() throws {
        guard #available(iOS 14.0, *) else {
            throw XCTSkip("Unsupported iOS version")
        }

        // FIXME: We'll need to find a way to make the test work the new pasteboard rules
        //
        // See:
        // - https://developer.apple.com/forums/thread/713770
        // - https://sarunw.com/posts/uipasteboard-privacy-change-ios16/
        // - https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/issues/696
        XCTExpectFailure("Paste board access has changed in iOS 16 and this test is now failing")

        let expect = expectation(description: "Could read nominal auth code from pasteboard")
        let pasteboard = UIPasteboard.general
        pasteboard.string = "123456"

        UIPasteboard.general.detectAuthenticatorCode { result in
            switch result {
            case .success(let authenticationCode):
                XCTAssertEqual(authenticationCode, "123456")
                expect.fulfill()
            case .failure:
                // Do nothing, by not fulfilling the expectation, the test will fail.
                return
            }
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testLeadingZeroInAuthCodePreserved() throws {
        guard #available(iOS 14.0, *) else {
            throw XCTSkip("Unsupported iOS version")
        }

        // FIXME: We'll need to find a way to make the test work the new pasteboard rules
        //
        // See:
        // - https://developer.apple.com/forums/thread/713770
        // - https://sarunw.com/posts/uipasteboard-privacy-change-ios16/
        // - https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/issues/696
        XCTExpectFailure("Paste board access has changed in iOS 16 and this test is now failing")

        let expect = expectation(description: "Could read leading zero auth code from pasteboard")
        let pasteboard = UIPasteboard.general
        pasteboard.string = "012345"

        UIPasteboard.general.detectAuthenticatorCode { result in
            switch result {
            case .success(let authenticationCode):
                XCTAssertEqual(authenticationCode, "012345")
                expect.fulfill()
            case .failure:
                // Do nothing, by not fulfilling the expectation, the test will fail.
                return
            }
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
