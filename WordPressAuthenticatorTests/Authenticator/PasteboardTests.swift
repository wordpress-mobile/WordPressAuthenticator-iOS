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

        if #available(iOS 16, *) {
            XCTExpectFailure("UIPastboard support has changed in iOS 16 and we haven't updated the tests yet")
        }

        let expect = expectation(description: "Could read nominal auth code from pasteboard")
        let pasteboard = UIPasteboard.general
        pasteboard.string = "123456"

        UIPasteboard.general.detectAuthenticatorCode { result in
            if #available(iOS 16, *) {
                XCTExpectFailure("UIPastboard support has changed in iOS 16 and we haven't updated the tests yet")
            }

            switch result {
                case .success(let authenticationCode):
                    XCTAssertEqual(authenticationCode, "123456")
                case .failure:
                    XCTAssert(false)
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testLeadingZeroInAuthCodePreserved() throws {
        guard #available(iOS 14.0, *) else {
            throw XCTSkip("Unsupported iOS version")
        }

        if #available(iOS 16, *) {
            XCTExpectFailure("UIPastboard support has changed in iOS 16 and we haven't updated the tests yet")
        }

        let expect = expectation(description: "Could read leading zero auth code from pasteboard")
        let pasteboard = UIPasteboard.general
        pasteboard.string = "012345"

        UIPasteboard.general.detectAuthenticatorCode { result in
            switch result {
                case .success(let authenticationCode):
                    XCTAssertEqual(authenticationCode, "012345")
                case .failure:
                    XCTAssert(false)
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }}
