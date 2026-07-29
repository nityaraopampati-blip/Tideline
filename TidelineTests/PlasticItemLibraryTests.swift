import XCTest
@testable import Tideline

final class PlasticItemLibraryTests: XCTestCase {
    private let library = PlasticItemLibrary.shared

    func testBundledDataLoads() {
        XCTAssertEqual(library.items.count, 20)
        XCTAssertEqual(library.quizQuestions.count, 10)
    }

    func testExactNameMatches() {
        XCTAssertEqual(library.match(query: "Plastic water bottle")?.name, "Plastic water bottle")
    }

    func testCaseInsensitiveMatch() {
        XCTAssertEqual(library.match(query: "PLASTIC STRAW")?.name, "Plastic straw")
    }

    func testShortQueryMatchesFullSeededName() {
        XCTAssertEqual(library.match(query: "water bottle")?.name, "Plastic water bottle")
    }

    func testLongerPhraseMatchesShorterSeededName() {
        // Brief's own example: "plastic drinking straw" should match "Plastic straw".
        XCTAssertEqual(library.match(query: "plastic drinking straw")?.name, "Plastic straw")
    }

    func testSingleWordMatch() {
        XCTAssertEqual(library.match(query: "straw")?.name, "Plastic straw")
    }

    func testMatchAcrossSlashInSeededName() {
        XCTAssertEqual(library.match(query: "chip bag")?.name, "Snack / chip bag")
    }

    func testMatchIgnoresExtraWords() {
        XCTAssertEqual(library.match(query: "plastic grocery shopping bag")?.name, "Plastic grocery bag")
    }

    func testPartialWordMatchForCompoundItem() {
        XCTAssertEqual(library.match(query: "toothbrush")?.name, "Plastic toothbrush")
    }

    func testUnrecognizedQueryReturnsNil() {
        XCTAssertNil(library.match(query: "asdfqwertyzxcv12345"))
    }

    func testEmptyQueryReturnsNil() {
        XCTAssertNil(library.match(query: ""))
        XCTAssertNil(library.match(query: "   "))
    }

    func testEveryItemMatchesItsOwnName() {
        for item in library.items {
            XCTAssertEqual(library.match(query: item.name)?.name, item.name, "Item '\(item.name)' should match itself")
        }
    }
}
