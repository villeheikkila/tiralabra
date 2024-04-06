import Foundation

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

func main() {
  let numberOfArgs = CommandLine.argc
  if numberOfArgs != 5 {
    print(
      "This program acceps four parameters, operation, algorithm, input file and output file in this format < encode | decode > <lz77 | huffman> <input file> <output file>"
    )
    return
  }

  let arguments = CommandLine.arguments

  guard let operation = Operation(rawValue: arguments[1]) else {
    print("Unsupported operation. Pick between 'encode' and 'decode'.")
    return
  }

  guard let algorithm = Algorithm(rawValue: arguments[2]) else {
    print("Unsupported algorithm. Pick either huffman or lz77.")
    return
  }

  let inputPath = arguments[3]
  if !isValidFilePath(path: inputPath) {
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
    try writeToFile(filePath: outputPath, text: text)
  } catch {
    print("Failed to read or write to the file. \(error)")
    return
  }
}

main()
