import Foundation

/*
* Huffman algorithm implementation
*/
enum Huffman {
  // --- types
  typealias Codes = [String: String]

  /*
  * this is a model that contains both the codes and the content
  * it can be used to decode and encode these values into a file
  */
  struct Model: Codable {
    let codes: Codes
    let content: String
  }

  // --- encode
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
      self.content = String(character)
    }

    // make a huffman coding node comparable by frequency, lower frequency is higher priority
    static func < (lhs: Node, rhs: Node) -> Bool {
      return lhs.frequency < rhs.frequency
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
      return lhs.frequency == rhs.frequency && lhs.content == rhs.content
    }
  }

  static func encode(_ content: String) -> String {
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

    // create a model that contains the codes and the content
    let model = Model(
      codes: codes, content: encodeContentWithHuffmanCodes(content: content, codes: codes))

    // encode the model into a JSON so it can be easily stored in a file and decoded from it
    guard let encodedData = try? JSONEncoder().encode(model) else {
      fatalError("failed to encode data")
    }

    // encode the JSON into a string
    guard let encodedAsString = String(data: encodedData, encoding: .utf8) else {
      fatalError("failed to convert data to string")
    }

    return encodedAsString
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

  // --- decode
  static func decode(_ content: String) -> String {
    // decode the Model from the string encoded content
    guard let utf8Data = content.data(using: .utf8) else { return "" }
    guard let model = try? JSONDecoder().decode(Model.self, from: utf8Data) else {
      fatalError("failed to decode huffman model from the given content")
    }

    var decodedContent = ""
    var currentCode = ""

    // loop through the encoded content and decode the content
    for currentCodePart in model.content {
      // construct the code until it is found in the dictionary
      currentCode.append(currentCodePart)
      // code is the value in the dictionary, key is the coded data
      if let decodedValue = model.codes.first(where: { _, value in value == currentCode }) {
        decodedContent.append(decodedValue.key)
        // reset the code and start again until the entire content is decoded
        currentCode = ""
      }
    }
    return decodedContent
  }
}
