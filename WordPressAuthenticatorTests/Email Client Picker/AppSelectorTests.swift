import XCTest
@testable import WordPressAuthenticator


struct URLMocks {

    static let mockAppList = ["gmail": "googlemail://", "airmail": "airmail://"]
}

class AppSelectorTests: XCTestCase {

    func testSelectorInitializationSuccess() {
        // Given
        let urlHandler = MockUrlHandler()
        urlHandler.canOpenUrlExpectation = expectation(description: "canOpenUrl called")
        // When
        let appSelector = AppSelector(with: URLMocks.mockAppList, sourceView: UIView(), urlHandler: urlHandler)
        // Then
        XCTAssertNotNil(appSelector)
        XCTAssertNotNil(appSelector?.alertController)
        XCTAssertEqual(appSelector!.alertController.actions.count, 3)
        waitForExpectations(timeout: 4) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testSelectorInitializationFailsWithNoApps() {
        // Given
        let urlHandler = MockUrlHandler()
        // When
        let appSelector = AppSelector(with: [:], sourceView: UIView(), urlHandler: urlHandler)
        // Then
        XCTAssertNil(appSelector)
    }

    func testSelectorInitializationFailsWithInvalidUrl() {
        // Given
        let urlHandler = MockUrlHandler()
        urlHandler.canOpenUrlExpectation = expectation(description: "canOpenUrl called")
        urlHandler.shouldOpenUrls = false
        // When
        let appSelector = AppSelector(with: URLMocks.mockAppList, sourceView: UIView(), urlHandler: urlHandler)
        // Then
        XCTAssertNil(appSelector)
        waitForExpectations(timeout: 4) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
