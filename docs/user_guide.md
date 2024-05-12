## User Guide

### Building the application

1. Install swift toolchain for your platform, it is available on package repositories on Linux and comes with XCode on macOS

2. Build the release build from the app

`swift build --configuration release`

### Running the build binary

1. Encode a file with one of the algos, replace INPUT and OUTPUT with desired paths. The file must be an UTF-8 encoded text file.

`.build/release/tiralabra encode huffman INPUT OUTPUT`

For example, running against the test data:

`.build/release/tiralabra encode huffman Examples/tko-aly.txt Examples/output`

2. Decode the file back. The file must be generated using this application as there is no clear specification for the byte format for either of the implemnted algorithms.

`.build/release/tiralabra decode huffman INPUT OUTPUT`

For example, running against the output generated in previous part

`.build/release/tiralabra encode huffman Examples/output Examples/decoded`
