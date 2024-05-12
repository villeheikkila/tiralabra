import XCTest

@testable import tiralabra

class HuffmanTests: XCTestCase {
    let text = """
    Salmi on ollut mukana vapaa­palo­kunnassa 35 vuotta ja osallistunut myös osaan viimeaikaisista tulipaloista Espoossa. Vapaapalo­kunnilla on sammutus­töissä tärkeä rooli. Pelastuslaitokset käyttävät niitä muun muassa isoissa tehtävissä.
    Leppävaaran vapaapalokunnan yhtenä erikoistumis­alueena on Salmen mukaan sammutusvesi­huolto: tehtävänä on varmistaa, että palopaikalle saadaan tarpeeksi vettä. Tätä varten vapaapalokunnalla on säiliöauto.
    """

    func testStringToCodingProducesCodes() {
        let nodes = Huffman.stringToCoding("Hei maailma!").codes
        XCTAssertFalse(nodes.isEmpty)
    }

    func testStringToCodingCanBeDecodedWithCodingToString() {
        let coded = Huffman.stringToCoding(text)
        let decoded = Huffman.codingToString(coded)
        XCTAssertEqual(text, decoded)
    }

    func testCodingToString() {
        let coding = Huffman.codingToString(
            (content: "1011000111", codes: ["o": "111", "e": "110", "h": "10", "l": "0"]))
        XCTAssertEqual(coding, "hello")
    }

    func testStringToCodingEachCharacterAppearsOnlyOnceInCoding() {
        let codes = Huffman.stringToCoding(text).codes
        let uniqueCodes = Set(codes.values)
        XCTAssertEqual(uniqueCodes.count, codes.count)
    }
}
