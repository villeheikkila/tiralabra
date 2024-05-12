## Testing Document

The project has simple test cases for both [Huffman Coding](../Sources/tiralabraTests/huffmanTests.swift) and [LZ77](../Sources/tiralabraTests/lz77Tests.swift). The tests are dead simple and test that the encoding and decoding functions work for a simple input. The input used for tests is short text in Finnish and few words.

### Running tests

You can run all tests by running `swift test` on the commandline. Coverage can be created with `swift test --enable-code-coverage` but the output is hard to parse.
