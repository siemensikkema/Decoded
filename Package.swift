// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Decoded",
    products: [
        .library(
            name: "Decoded",
            targets: ["Decoded"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Decoded",
            dependencies: []),
        .testTarget(
            name: "DecodedTests",
            dependencies: ["Decoded"]),
    ]
)
