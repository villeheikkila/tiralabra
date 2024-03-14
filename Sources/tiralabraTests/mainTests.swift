import XCTest

@testable import tiralabra

class mainTests: XCTestCase {
  func testExample() {
    XCTAssertEqual(combine(2, 2), 4)
  }

  static var allTests = [
    ("testExample", testExample)
  ]
}
