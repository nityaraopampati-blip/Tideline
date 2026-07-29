import XCTest
@testable import Tideline

final class PlasticItemLibraryTests: XCTestCase {
    func testBundledDataLoads() {
        let library = PlasticItemLibrary.shared
        XCTAssertEqual(library.items.count, 20)
        XCTAssertEqual(library.quizQuestions.count, 10)
    }
}
