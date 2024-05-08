import Foundation

/**
 * LZ77 algorithm implementation
 */
enum LZ77 {
    /**
      A token that represents a part of the LZ77 encoded data
     - `distance`: The distance to the start of the matched substring going backwards
     - `length`: The length of the matched substring
     - `nextChar`: A UTF-8 character that follows the matched substring if it exists
      */
    typealias Token = (distance: Int, length: Int, nextChar: Character?)

    /**
     A list of tokens that represent LZ77 encoded data
     */
    typealias Tokens = [Token]

    /**
     Converts a string into LZ77 encoded binary data
     - Parameters:
       - content: The string to be converted into LZ77 tokens
     - Returns: A data object containing the LZ77 encoded binary representation of the input string
     */
    static func stringToData(_ string: String) -> Data {
        tokensToData(stringToTokens(string))
    }

    static func tokensToData(_ tokens: Tokens) -> Data {
        var data = Data()
        for token in tokens {
            var distance = UInt16(token.distance).bigEndian
            withUnsafeBytes(of: &distance) { bytes in
                data.append(contentsOf: bytes)
            }
            var length = UInt8(token.length)
            withUnsafeBytes(of: &length) { bytes in
                data.append(contentsOf: bytes)
            }
            if let nextChar = token.nextChar, let charData = String(nextChar).data(using: .utf8) {
                data.append(charData)
            }
            // add delimiter after each token
            data.append(0)
        }
        return data
    }

    /**
      Converts a string into a sequence of LZ77 tokens
      - Parameters:
        - string: The string to be converted into LZ77 tokens
        - maxlookBackDistance: The maximum distance to look back to find a matching string, default value is 128
      - Returns: An array of tokens, where each token is a tuple containing the distance, length, and optionally the next character
     */
    static func stringToTokens(_ string: String, maxlookBackDistance: Int = 128) -> Tokens {
        let chars = string.map { $0 }
        var currentIndex = 0
        var encodedContent: Tokens = []
        // iterate over all the characters
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

    /**
     Converts a data object into a decoded string
     - Parameters:
        - data: The LZ77 encoded data
     - Returns: The decoded string
     */
    static func dataToString(_ data: Data) -> String {
        tokensToString(dataToTokens(data))
    }

    /**
     Converts binary data into LZ77 tokens
     - Parameters:
        - data: The binary data containing encoded tokens
     - Returns: An array of tokens, with each token containing a distance, a length and the next character if it exists
     */
    static func dataToTokens(_ data: Data) -> Tokens {
        var tokens = Tokens()
        let dataCount = data.count
        var index = 0
        // decode the tokens byte by byte
        while index < dataCount {
            // assemble 16-bit integer from two consecutive bytes
            let distance = Int(data[index]) << 8 | Int(data[index + 1])
            // move two bytes ahead to get the length
            index += 2
            let length = Int(data[index])
            // move another byte to get the first character
            index += 1
            // tmp variable to store the character
            var nextChar: Character? = nil
            if index < dataCount && data[index] != 0 {
                var charData = Data()
                // go on till we hit the delimiter
                while index < dataCount && data[index] != 0 {
                    charData.append(data[index])
                    index += 1
                }
                // decode the utf8 encoded string from the char data
                if let charString = String(data: charData, encoding: .utf8) {
                    nextChar = charString.first
                }
            }
            // skip the delimiter
            index += 1
            tokens.append((distance, length, nextChar))
        }
        return tokens
    }

    /**
     Reconstructs a string from an array of LZ77 tokens
     - Parameter tokens: An array of LZ77 tokens
     - Returns: The decoded original string
     */
    static func tokensToString(_ tokens: Tokens) -> String {
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
