import Foundation

/*
* This function handles parsing the command line arguments and calling the appropriate function
*/
func cli(arguments: [String]) {
  guard let operation = Operation(rawValue: arguments[1]) else {
    print("Unsupported operation. Pick between 'encode' and 'decode'.")
    return
  }

  guard let algorithm = Algorithm(rawValue: arguments[2]) else {
    print("Unsupported algorithm. Pick either huffman or lz77.")
    return
  }

  let inputPath = arguments[3]
  guard isFileExists(path: inputPath) else {
    print("Invalid input file path")
    return
  }

  let outputPath = arguments[4]

  print(
    "\(operation.description) content with \(algorithm) algorithm with \(inputPath) and writing to \(outputPath)"
  )

  do {
    let content = try readFileContent(path: inputPath)
    let text =
      switch operation {
      case .decode:
        algorithm.decode(content)
      case .encode:
        algorithm.encode(content)
      }
    try writeTextToFile(filePath: outputPath, text: text)
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
