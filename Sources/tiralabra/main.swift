import Foundation

func main() {
  let arguments = CommandLine.arguments
  guard arguments.count == 5 else {
    return print(
      """
      This program requires four parameters. They must be in the following format, separated by spaces: 
      encode | decode
      lz77 | huffman
      input file
      output file
      """
    )
  }
  cli(arguments: arguments)
}

main()
