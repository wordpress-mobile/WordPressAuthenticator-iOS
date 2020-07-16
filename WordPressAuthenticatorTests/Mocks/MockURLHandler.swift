import Foundation
import XCTest
@testable import WordPressAuthenticator

class MockUrlHandler: URLHandler {

    var shouldOpenUrls = true
    var lastUrl: URL?

    var canOpenUrlExpectation: XCTestExpectation?
    var openUrlExpectation: XCTestExpectation?

    func canOpenURL(_ url: URL) -> Bool {
        canOpenUrlExpectation?.fulfill()
        canOpenUrlExpectation = nil
        return shouldOpenUrls
    }

    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        openUrlExpectation?.fulfill()
        lastUrl = url
    }
}

