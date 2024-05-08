import Foundation

/*
 * This enum represents all supported algorithms supported by this utility
 */
enum Algorithm: String {
    enum AlgorithmError: Error {
        case decodingCodesFailed
        case encodingCodesFailed
        case conversionFailed
    }

    case lz77, huffman

    // TODO: This a total mess
    func encode(_ inputPath: String, _ outputPath: String) throws {
        switch self {
        case .lz77:
            let fileContent = try FileUtils.readFileContent(path: inputPath)
            let data = LZ77.stringToData(fileContent)
            let fileURL = URL(fileURLWithPath: outputPath)
            try data.write(to: fileURL, options: .atomic)
            let intialFileSize = try? FileUtils.fileSize(path: inputPath)
            let encodedFileSize = try? FileUtils.fileSize(path: "\(outputPath)")
            if let initial = intialFileSize, let encoded = encodedFileSize {
                print("Initial size: \(initial) bytes")
                print("LZ77 encoded size: \(encoded) bytes")
                print("LZ77 compression: \((1 - (Double(encoded) / Double(initial))) * 100)%")
            }
        case .huffman:
            /*
             * Encode the content from a file and write the encoded content to a binary file and the huffman codes to a separate file (.bin and .codes respectively)
             */
            let fileContent = try FileUtils.readFileContent(path: inputPath)
            let (content, codes) = Huffman.stringToCoding(fileContent)
            guard let jsonEncodedCodes = try? JSONEncoder().encode(codes) else {
                throw AlgorithmError.encodingCodesFailed
            }
            guard let jsonStringCodes = String(data: jsonEncodedCodes, encoding: .utf8) else {
                throw AlgorithmError.conversionFailed
            }
            // write the encoded content to a binary file ending in .bin
            try BinaryUtils.bitStringToFile(content, outputPath: "\(outputPath).bin")
            // write huffman codes into a separte file ending in .codes
            try FileUtils.writeTextToFile(filePath: "\(outputPath).codes", text: jsonStringCodes)
            let intialFileSize = try? FileUtils.fileSize(path: inputPath)
            let encodedFileSize = try? FileUtils.fileSize(path: "\(outputPath).bin")
            let huffmanCodesSize = try? FileUtils.fileSize(path: "\(outputPath).codes")
            if let initial = intialFileSize, let encoded = encodedFileSize, let codes = huffmanCodesSize {
                print("Initial file size: \(initial) bytes")
                print("Huffman coded size: \(encoded) bytes")
                print("Huffman codes size: \(codes) bytes")
                print("Huffman compression: \((1 - (Double(encoded) / Double(initial))) * 100)%")
                print("Huffman compression ratio with codes: \(Double(initial) / Double(encoded + codes))")
            }
        }
    }

    func decode(_ inputPath: String, _ outputPath: String) throws {
        switch self {
        case .lz77:
            let fileURL = URL(fileURLWithPath: inputPath)
            let data = try Data(contentsOf: fileURL)
            let string = LZ77.dataToString(data)
            try FileUtils.writeTextToFile(filePath: outputPath, text: string)
        case .huffman:
            /*
             * There are two files that are needed, the .bin file and the .codes file. bin file contains the encoded content and the codes file contains the huffman codes.
             * Huffman coding has no specific format for saving the codes so I decided to encode the codes in a JSON format.
             * The binary file contains the encoded content. Both files much match in name and be stored in the same location
             */
            let codesString = try FileUtils.readFileContent(path: "\(inputPath).codes")
            guard let codesUtf8Data = codesString.data(using: .utf8) else {
                throw AlgorithmError.decodingCodesFailed
            }
            let codes = try JSONDecoder().decode([String: String].self, from: codesUtf8Data)
            let binaryString = try BinaryUtils.fileToBitString("\(inputPath).bin")
            let decoded = Huffman.codingToString((content: binaryString, codes: codes))
            try FileUtils.writeTextToFile(filePath: outputPath, text: decoded)
        }
    }
}
