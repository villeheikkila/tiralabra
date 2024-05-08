import Foundation

/*
 * This function handles parsing the command line arguments and calling the appropriate function
 */
func cli(arguments: [String]) {
    guard arguments.count == 5 else {
        return print(
            """
            This program requires four parameters. They must be in the following format, separated by spaces:
            encode | decode
            lz77 | huffman
            input
            output
            """
        )
    }

    guard let operation = Operation(rawValue: arguments[1]) else {
        print("Unsupported operation. Pick between 'encode' and 'decode'.")
        return
    }

    guard let algorithm = Algorithm(rawValue: arguments[2]) else {
        print("Unsupported algorithm. Pick either huffman or lz77.")
        return
    }

    let inputPath = arguments[3]
    let outputPath = arguments[4]

    print(
        "\(operation.description) content with \(algorithm) algorithm with \(inputPath) and writing to \(outputPath)"
    )

    do {
        switch operation {
        case .decode:
            try algorithm.decode(inputPath, outputPath)
        case .encode:
            try algorithm.encode(inputPath, outputPath)
        }
    } catch {
        print("Failed to read or write to the file. \(error)")
        return
    }
}

/*
 * Enum that represents all supported operations by this utility
 */
enum Operation: String {
    case encode
    case decode

    var description: String {
        switch self {
        case .encode:
            return "Encoding"
        case .decode:
            return "Decoding"
        }
    }
}
