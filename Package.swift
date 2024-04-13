// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "tiralabra",
    products: [
        .executable(name: "tiralabra", targets: ["tiralabra"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(name: "tiralabra", dependencies: []),
        .testTarget(name: "tiralabraTests", dependencies: ["tiralabra"]),
    ]
)
