@testable import WordPressAuthenticator
import XCTest

class StringRandomTests: XCTestCase {

    func testSecureRandomStringLengthIsAsRequested() throws {
        XCTAssertEqual(
            try XCTUnwrap(String.secureRandomString(using: Set("abc"), withLength: 10)).count,
            10
        )
    }

    func testSecureRandomStringUsesGivenCharactersOnly() throws {
        // Using length 300 with 3 characters be relatively sure sure we'll get all of the
        // characters at least once.
        let randomString = try XCTUnwrap(String.secureRandomString(using: Set("abc"), withLength: 30))

        XCTAssertEqual(
            CharacterSet(charactersIn: randomString),
            CharacterSet(charactersIn: "abc")
        )
    }

    func testSecureRandomStringsAreDifferent() throws {
        let characters = Set("abcdefghijklmnopqrstuvwxyz")
        let length = 100

        // It is _possible_ for the strings to be equal. However, it should be so unlikely that a
        // test failure will most definitely mean an error in the code, rather than a legit case of
        // the same random string being generated twice.
        XCTAssertNotEqual(
            try String.secureRandomString(using: characters, withLength: length),
            try String.secureRandomString(using: characters, withLength: length)
        )
    }

    // MARK: -

    func testRandomStringLengthIsAsRequested() {
        XCTAssertEqual(
            String.randomString(using: Set("abc"), withLength: 10).count,
            10
        )
    }

    func testRandomStringUsesGivenCharactersOnly() {
        // Using length 300 with 3 characters be relatively sure sure we'll get all of the
        // characters at least once.
        let randomString = String.randomString(using: Set("abc"), withLength: 30)

        XCTAssertEqual(
            CharacterSet(charactersIn: randomString),
            CharacterSet(charactersIn: "abc")
        )
    }

    func testRandomStringsAreDifferent() {
        let characters = Set("abcdefghijklmnopqrstuvwxyz")
        let length = 100

        // It is _possible_ for the strings to be equal. However, it should be so unlikely that a
        // test failure will most definitely mean an error in the code, rather than a legit case of
        // the same random string being generated twice.
        XCTAssertNotEqual(
            String.randomString(using: characters, withLength: length),
            String.randomString(using: characters, withLength: length)
        )
    }
}
