import Foundation

func readFileContent(path: String) throws -> String {
  return try String(contentsOfFile: path, encoding: .utf8)
}

func writeToFile(filePath: String, text: String) throws {
  let url = URL(fileURLWithPath: filePath)
  try text.write(to: url, atomically: false, encoding: .utf8)
}

func isValidFilePath(path: String) -> Bool {
  return FileManager.default.fileExists(atPath: path)
}
