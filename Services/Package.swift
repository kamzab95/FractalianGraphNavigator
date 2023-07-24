// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "GraphService",
            targets: ["GraphService"])
    ],
    dependencies: [
        .package(path: "GraphMLParser")
    ],
    targets: [
        .target(
            name: "GraphService",
            dependencies: ["GraphMLParser"]),
        .testTarget(
            name: "GraphServiceTests",
            dependencies: ["GraphService"],
            resources: [.process("Resources")]),
    ]
)
