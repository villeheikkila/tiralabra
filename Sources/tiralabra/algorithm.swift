import Foundation

/*
 * This enum represents all supported algorithms supported by this utility
 */
enum Algorithm: String {
    case lz77, huffman

    func encode(_ inputPath: String, _ outputPath: String) throws {
        switch self {
        case .lz77:
            try LZ77.encodeFromFileToFile(inputPath: inputPath, outputPath: outputPath)
            let intialFileSize = try? FileUtils.fileSize(path: inputPath)
            let encodedFileSize = try? FileUtils.fileSize(path: "\(outputPath).lz77")
            if let initial = intialFileSize, let encoded = encodedFileSize {
                print("Initial size: \(initial) bytes")
                print("LZ77 encoded size: \(encoded) bytes")
                print("LZ77 compression ratio: \(Double(initial) / Double(encoded))")
            }
        case .huffman:
            try Huffman.encodeFromFileToFile(inputPath: inputPath, outputPath: outputPath)
            let intialFileSize = try? FileUtils.fileSize(path: inputPath)
            let encodedFileSize = try? FileUtils.fileSize(path: "\(outputPath).bin")
            let huffmanCodesSize = try? FileUtils.fileSize(path: "\(outputPath).codes")
            if let initial = intialFileSize, let encoded = encodedFileSize, let codes = huffmanCodesSize {
                print("Initial file size: \(initial) bytes")
                print("Huffman coded size: \(encoded) bytes")
                print("Huffman codes size: \(codes) bytes")
                print("Huffman compression ratio: \(Double(initial) / Double(encoded))")
                print("Huffman compression ratio with codes: \(Double(initial) / Double(encoded + codes))")
            }
        }
    }

    func decode(_ inputPath: String, _ outputPath: String) throws {
        switch self {
        case .lz77:
            try LZ77.decodeFromFileToFile(inputPath: inputPath, outputPath: outputPath)
        case .huffman:
            try Huffman.decodeFromFileToFile(inputPath: inputPath, outputPath: outputPath)
        }
    }
}
