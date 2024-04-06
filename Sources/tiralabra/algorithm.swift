/*
* This enum represents all supported algorithms supported by this utility
*/
enum Algorithm: String {
  case lz77, huffman

  func encode(_ content: String) -> String {
    switch self {
    case .lz77:
      LZ77.encode(content)
    case .huffman:
      Huffman.encode(content)
    }
  }

  func decode(_ content: String) -> String {
    switch self {
    case .lz77:
      LZ77.decode(content)
    case .huffman:
      Huffman.decode(content)
    }
  }
}
