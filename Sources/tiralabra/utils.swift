import Foundation

enum FileUtils {
    enum FileError: Error {
        case failedToReadSize
    }

    static func readFileContent(path: String) throws -> String {
        return try String(contentsOfFile: path, encoding: .utf8)
    }

    static func writeTextToFile(filePath: String, text: String) throws {
        let url = URL(fileURLWithPath: filePath)
        try text.write(to: url, atomically: false, encoding: .utf8)
    }

    static func isFileExists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    static func fileSize(path: String) throws -> UInt64? {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
        if let fileSize = fileAttributes[FileAttributeKey.size] as? UInt64 {
            return fileSize
        }
        throw FileError.failedToReadSize
    }
}

enum BinaryUtils {
    enum BinaryError: Error {
        case invalidBinaryCharacter
    }

    static func bitStringToFile(_ bits: String, outputPath: String) throws {
        // create a data object to store the huffman coding, initialize to the right capacity
        var data = Data(capacity: bits.count / 8)

        var bitsProcedded = 0
        var currentByte: UInt8 = 0

        // convert character bits into bytes
        for bit in bits {
            if bit == "1" {
                // shift the current byte left by one and add 1
                currentByte = (currentByte << 1) | 1
            } else if bit == "0" {
                // shift the current byte left by one, adding 0
                currentByte <<= 1
            } else {
                throw BinaryError.invalidBinaryCharacter
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

        let url = URL(fileURLWithPath: outputPath)
        try data.write(to: url)
    }

    static func fileToBitString(_ inputPath: String) throws -> String {
        let file = URL(fileURLWithPath: inputPath)
        return try Data(contentsOf: file).map { byte -> String in
            // Convert each byte to a binary string
            let binaryByte = String(byte, radix: 2)
            // Ensure leading zeros are included to make each byte a full 8 bits
            return .init(repeating: "0", count: 8 - binaryByte.count) + binaryByte
        }.joined()
    }
}
