// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModularModel",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "ModularModel",
            targets: ["ModularModel"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ModularModel",
            dependencies: []),
        .testTarget(
            name: "ModularModelTests",
            dependencies: ["ModularModel"]),
    ]
)
