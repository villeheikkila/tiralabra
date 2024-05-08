# tiralabra

## Documentation

[Specification Document](./docs/specification_document.md)

## Weekly Reports

[Weekly Report 1](./docs/weekly_report_1.md)

[Weekly Report 2](./docs/weekly_report_2.md)

[Weekly Report 3](./docs/weekly_report_3.md)

[Weekly Report 4](./docs/weekly_report_4.md)

[Weekly Report 5](./docs/weekly_report_5.md)

[Weekly Report 6](./docs/weekly_report_6.md)

## How to test

1. Install swift toolchain for your platform

2. Build the release build from the app

`swift build --configuration release`

3. Encode a file with one of the algos, replace INPUT and OUTPUT with desired paths

`.build/release/tiralabra encode huffman INPUT OUTPUT`

4. Decode the file back

`.build/release/tiralabra decode huffman INPUT OUTPUT`
