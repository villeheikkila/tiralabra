enum Algorithm: String {
  case lz77, huffman

  func encode(_ content: String) -> String {
    switch self {
    case .lz77:
      ""
    case .huffman:
      Huffman.encode(content)
    }
  }

  func decode(_ content: String) -> String {
    switch self {
    case .lz77:
      ""
    case .huffman:
      Huffman.decode(content)
    }
  }
}
