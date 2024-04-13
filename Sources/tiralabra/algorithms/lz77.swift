import Foundation

/*
 * LZ77 algorithm implementation
 */
enum LZ77 {
    // --- types
    typealias Token = (distance: Int, length: Int, nextChar: Character?)
    typealias Tokens = [Token]

    enum LZ77Error: Error {
        case dataConverionFailed
    }

    // TEMP!!! This in very inefficient and should be replaced with a more efficient data structure
    struct LZ77Tuple: Codable {
        var distance: Int
        var length: Int
        var nextChar: String?

        init(encoding: Token) {
            distance = encoding.distance
            length = encoding.length
            nextChar = if let nextChar = encoding.nextChar { String(nextChar) } else { nil }
        }
    }

    // --- file operations
    static func decodeFromFileToFile(inputPath: String, outputPath: String) throws {
        let fileContent = try FileUtils.readFileContent(path: inputPath)
        guard let jsonData = fileContent.data(using: .utf8) else {
            throw LZ77Error.dataConverionFailed
        }
        let lz77Tuples = try JSONDecoder().decode([LZ77Tuple].self, from: jsonData)
        let decodedString = LZ77.decode(
            lz77Tuples.map {
                Token(distance: $0.distance, length: $0.length, nextChar: $0.nextChar?.first)
            })
        try FileUtils.writeTextToFile(filePath: outputPath, text: decodedString)
    }

    static func encodeFromFileToFile(inputPath: String, outputPath: String) throws {
        let fileContent = try FileUtils.readFileContent(path: inputPath)
        let encoded = LZ77.encode(fileContent)
        let jsonEncoded = try JSONEncoder().encode(encoded.map { LZ77Tuple(encoding: $0) })
        guard let jsonString = String(data: jsonEncoded, encoding: .utf8) else {
            throw LZ77Error.dataConverionFailed
        }
        try FileUtils.writeTextToFile(filePath: "\(outputPath).lz77", text: jsonString)
    }

    // --- encode
    static func encode(_ content: String, maxlookBackDistance: Int = 128) -> Tokens {
        let chars = content.map { $0 }
        var currentIndex = 0
        var encodedContent: Tokens = []

        while currentIndex < chars.count {
            var distance = 0
            var length = 0
            var isMatchFound = false
            // search for the longest match in the look back window
            for lookBackDistance in max(currentIndex - maxlookBackDistance, 0) ..< currentIndex {
                var matchLength = 0
                while currentIndex + matchLength < chars.count
                    && chars[matchLength + lookBackDistance] == chars[matchLength + currentIndex]
                {
                    isMatchFound = true
                    matchLength += 1
                }
                if isMatchFound && matchLength > length {
                    distance = currentIndex - lookBackDistance
                    length = matchLength
                }
            }

            // determine the next character after the match
            let nextChar = currentIndex + length < chars.count ? chars[currentIndex + length] : nil
            encodedContent.append((distance, length, nextChar))
            currentIndex += length + 1
        }

        return encodedContent
    }

    // --- decode
    static func decode(_ tokens: Tokens) -> String {
        var decodedContent = ""
        // iterate over the tokens and reconstruct the original content
        for token in tokens {
            let start = max(decodedContent.count - token.distance, 0)
            let end = start + token.length
            // check that the start index is within the bounds of the decoded result
            if start < decodedContent.count {
                for offsetBy in start ..< end {
                    let i = decodedContent.index(decodedContent.startIndex, offsetBy: offsetBy)
                    if i < decodedContent.endIndex {
                        // Add the found character to the decoded result
                        decodedContent.append(decodedContent[i])
                    }
                }
            }
            // add the character that couldn't be represented with previous inputs
            if let nextChar = token.nextChar {
                decodedContent.append(nextChar)
            }
        }
        return decodedContent
    }
}
