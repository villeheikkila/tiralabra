import Foundation

/*
 * Huffman algorithm implementation
 */
enum Huffman {
    // --- types
    typealias Codes = [String: String]
    typealias HuffmanEncoding = (content: String, codes: Codes)

    enum HuffmanError: Error {
        case decodingCodesFailed
        case encodingCodesFailed
        case convertingCodesToStringFailed
    }

    // --- file operations

    /*
     * There are two files that are needed, the .bin file and the .codes file. bin file contains the encoded content and the codes file contains the huffman codes.
     * Huffman coding has no specific format for saving the codes so I decided to encode the codes in a JSON format.
     * The binary file contains the encoded content. Both files much match in name and be stored in the same location
     */
    static func decodeFromFileToFile(inputPath: String, outputPath: String) throws {
        let codesString = try FileUtils.readFileContent(path: "\(inputPath).codes")
        guard let codesUtf8Data = codesString.data(using: .utf8) else {
            throw HuffmanError.decodingCodesFailed
        }
        let codes = try JSONDecoder().decode([String: String].self, from: codesUtf8Data)
        let binaryString = try BinaryUtils.fileToBitString("\(inputPath).bin")
        let decoded = Huffman.decode((content: binaryString, codes: codes))
        try FileUtils.writeTextToFile(filePath: outputPath, text: decoded)
    }

    /*
     * Encode the content from a file and write the encoded content to a binary file and the huffman codes to a separate file (.bin and .codes respectively)
     */
    static func encodeFromFileToFile(inputPath: String, outputPath: String) throws {
        let fileContent = try FileUtils.readFileContent(path: inputPath)
        let (content, codes) = Huffman.encode(fileContent)
        guard let jsonEncodedCodes = try? JSONEncoder().encode(codes) else {
            throw HuffmanError.encodingCodesFailed
        }
        guard let jsonStringCodes = String(data: jsonEncodedCodes, encoding: .utf8) else {
            throw HuffmanError.convertingCodesToStringFailed
        }
        // write the encoded content to a binary file ending in .bin
        try BinaryUtils.bitStringToFile(content, outputPath: "\(outputPath).bin")
        // write huffman codes into a separte file ending in .codes
        try FileUtils.writeTextToFile(filePath: "\(outputPath).codes", text: jsonStringCodes)
    }

    // --- encode
    static func encode(_ content: String) -> HuffmanEncoding {
        // count the frequency of each character in the content
        var characterFrequency = [Character: Int]()
        for character in content {
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

            // append the comined node back to the nodes
            let parent = Node(frequency: frequency, content: content)
            parent.left = left
            parent.right = right
            nodes.append(parent)
        }

        // recursively generate the huffman codes
        let codes = generateHuffmanCode(nodes.first, prefix: "")
        return (content: encodeContentWithHuffmanCodes(content: content, codes: codes), codes)
    }

    private static func generateHuffmanCode(_ node: Node?, prefix: String) -> Codes {
        guard let node else { return [:] }
        guard let leftNode = node.left, let rigthNode = node.right else {
            return [node.content: prefix]
        }

        var left = generateHuffmanCode(leftNode, prefix: prefix + "0")
        let right = generateHuffmanCode(rigthNode, prefix: prefix + "1")

        for (key, value) in right {
            left[key] = value
        }

        return left
    }

    private static func encodeContentWithHuffmanCodes(content: String, codes: Codes)
        -> String
    {
        // go through each character in the content and encode it
        content.reduce("") { result, character in
            if let code = codes[String(character)] {
                result + code
            } else {
                result
            }
        }
    }

    private class Node: Comparable {
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
            return lhs.frequency < rhs.frequency
        }

        static func == (lhs: Node, rhs: Node) -> Bool {
            return lhs.frequency == rhs.frequency && lhs.content == rhs.content
        }
    }

    // --- decode
    static func decode(_ encoding: HuffmanEncoding) -> String {
        var decodedContent = ""
        var currentCode = ""

        // loop through the encoded content and decode the content
        for currentCodePart in encoding.content {
            // construct the code until it is found in the dictionary
            currentCode.append(currentCodePart)
            // code is the value in the dictionary, key is the coded data
            if let decodedValue = encoding.codes.first(where: { _, value in value == currentCode }) {
                decodedContent.append(decodedValue.key)
                // reset the code and start again until the entire content is decoded
                currentCode = ""
            }
        }
        return decodedContent
    }
}
