import XCTest
@testable import MediaService

final class MediaServiceTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MediaService().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
