import XCTest
@testable import MVVMKit

final class MVVMKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MVVMKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
