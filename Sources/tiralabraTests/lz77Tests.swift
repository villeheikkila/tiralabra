import XCTest

@testable import tiralabra

class LZ77Tests: XCTestCase {
    let text = """
    Salmi on ollut mukana vapaa­palo­kunnassa 35 vuotta ja osallistunut myös osaan viimeaikaisista tulipaloista Espoossa. Vapaapalo­kunnilla on sammutus­töissä tärkeä rooli. Pelastuslaitokset käyttävät niitä muun muassa isoissa tehtävissä.
    Leppävaaran vapaapalokunnan yhtenä erikoistumis­alueena on Salmen mukaan sammutusvesi­huolto: tehtävänä on varmistaa, että palopaikalle saadaan tarpeeksi vettä. Tätä varten vapaapalokunnalla on säiliöauto.
    """

    func testStringToDataDataToStringProducesSameString() {
        let encoded = LZ77.stringToData(text)
        let decoded = LZ77.dataToString(encoded)
        XCTAssertEqual(decoded, text)
    }

    func testThatRepeatingTextIsProperlyEncodedAndDecoded() {
        let text = "hei maailma"
        let encoded = LZ77.stringToData(text)
        let decoded = LZ77.dataToString(encoded)
        XCTAssertEqual(decoded, text)
    }

    func testStringToDataCompressesRepeatingCharacters() {
        let input = String(repeating: "a", count: 100)
        let encoded = LZ77.stringToData(input)
        XCTAssertTrue(encoded.count < input.count)
    }
}
