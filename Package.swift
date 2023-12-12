// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aoc",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "../aoc-utils", from: "0.0.9")
    ],
    targets: [
        .executableTarget(
            name: "aoc",
            dependencies: [
            .product(name: "AocUtils", package: "aoc-utils")
        ]),
    ]
)
