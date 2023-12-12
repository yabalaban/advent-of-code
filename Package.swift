// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aoc",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/yabalaban/advent-of-code-swift-utils", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "aoc",
            dependencies: [
            .product(name: "AocUtils", package: "advent-of-code-swift-utils")
        ]),
    ]
)
