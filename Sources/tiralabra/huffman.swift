import Foundation

/// Huffman algorithm implementation
enum Huffman {
    typealias HuffmanCodes = [String: String]
    typealias HuffmanCoding = (content: String, codes: HuffmanCodes)

    /**
      Converts a string into a huffman coding
      - Parameters:
        - string: The string to be converted into Huffman coding
      - Returns: A tuple with huffman encoded string and codes
     */
    static func stringToCoding(_ string: String) -> HuffmanCoding {
        // count the frequency of each character in the content
        var characterFrequency = [Character: Int]()
        for character in string {
            characterFrequency[character, default: 0] += 1
        }

        // construct the nodes from the character frequency dictionary
        var nodes: [Node] = characterFrequency.map { character, frequency in
            .init(frequency: frequency, character: character)
        }

        // construct the huffman tree
        while nodes.count > 1 {
            // sort the nodes by frequency, from lowest to highest
            nodes.sort()
            // get the two nodes with the lowest frequency
            let left = nodes.removeLast()
            let right = nodes.removeLast()

            // combine the the nodes and their frequencies
            let content = "\(left.content)\(right.content)"
            let frequency = left.frequency + right.frequency

            // append the combined node back to the nodes
            let parent = Node(frequency: frequency, content: content)
            parent.left = left
            parent.right = right
            nodes.append(parent)
        }

        // recursively generate the huffman codes
        let codes = nodeToCodes(nodes.first, prefix: "")
        return (content: encodeStringWithCodes(string: string, codes: codes), codes)
    }

    /**
     Converts a Huffman tree into a dictionary
      - Parameters:
         - node: The current `Node` of the Huffman tree being processed
         - prefix: The Huffman code formed so far
      - Returns: Huffman codes after this node has been converted
     */
    static func nodeToCodes(_ node: Node?, prefix: String) -> HuffmanCodes {
        guard let node else { return [:] }
        guard let leftNode = node.left, let rigthNode = node.right else {
            return [node.content: prefix]
        }

        var left = nodeToCodes(leftNode, prefix: prefix + "0")
        let right = nodeToCodes(rigthNode, prefix: prefix + "1")

        for (key, value) in right {
            left[key] = value
        }

        return left
    }

    /**
      Converts Huffman coding back to the original string
      - Parameters:
        - string: The string that is encoded
        - codes: Huffman coding to be used to encode the string
      - Returns: the encoded string
     */
    static func encodeStringWithCodes(string: String, codes: HuffmanCodes) -> String {
        // go through each character in the content and encode it
        string.reduce("") { result, character in
            if let code = codes[String(character)] {
                result + code
            } else {
                result
            }
        }
    }

    static func bitStringToData(string: String) -> Data {
        var data = Data(capacity: string.count / 8)

        var bitsProcedded = 0
        var currentByte: UInt8 = 0

        // convert character bits into bytes
        for bit in string {
            if bit == "1" {
                // shift the current byte left by one and add 1
                currentByte = (currentByte << 1) | 1
            } else if bit == "0" {
                // shift the current byte left by one, adding 0
                currentByte <<= 1
            } else {
                fatalError("invalid bit string")
            }

            bitsProcedded += 1
            if bitsProcedded % 8 == 0 {
                // add the full byte to the data object
                data.append(currentByte)
                currentByte = 0
            }
        }

        // pad the last byte if needed
        if bitsProcedded % 8 != 0 {
            let shiftsToCompleteAByte = 8 - (bitsProcedded % 8)
            // shift as many times as required
            currentByte <<= shiftsToCompleteAByte
            data.append(currentByte)
        }

        return data
    }

    class Node: Comparable {
        // frequency of the content
        let frequency: Int
        var content: String

        var left: Node?
        var right: Node?

        init(frequency: Int, content: String) {
            self.frequency = frequency
            self.content = content
        }

        init(frequency: Int, character: Character) {
            self.frequency = frequency
            content = String(character)
        }

        // make a huffman coding node comparable by frequency, lower frequency is higher priority
        static func < (lhs: Node, rhs: Node) -> Bool {
            return lhs.frequency > rhs.frequency
        }

        static func == (lhs: Node, rhs: Node) -> Bool {
            return lhs.frequency == rhs.frequency && lhs.content == rhs.content
        }
    }

    /**
      Converts Huffman coding back to the original string
      - Parameters:
        - coding: The Huffman coding to be decoded
      - Returns: the reconstructed original string
     */
    static func codingToString(_ coding: HuffmanCoding) -> String {
        var decodedContent = ""
        var currentCode = ""

        // loop through the encoded content and decode the content
        for currentCodePart in coding.content {
            // construct the code until it is found in the dictionary
            currentCode.append(currentCodePart)
            // code is the value in the dictionary, key is the coded data
            if let decodedValue = coding.codes.first(where: { _, value in value == currentCode }) {
                decodedContent.append(decodedValue.key)
                // reset the code and start again until the entire content is decoded
                currentCode = ""
            }
        }
        return decodedContent
    }
}
