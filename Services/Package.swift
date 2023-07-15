// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "GraphService",
            targets: ["GraphService"]),
        .library(
            name: "GraphServiceMocks",
            targets: ["GraphServiceMocks"]),
    ],
    dependencies: [
        .package(path: "GraphMLParser")
    ],
    targets: [
        .target(
            name: "GraphService",
            dependencies: ["GraphMLParser"]),
        .target(
            name: "GraphServiceMocks",
            dependencies: ["GraphService"],
            path: "Mocks/GraphServiceMocks"),
        .testTarget(
            name: "GraphServiceTests",
            dependencies: ["GraphService"],
            resources: [.process("Resources")]),
    ]
)
