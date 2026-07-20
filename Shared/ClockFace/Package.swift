// swift-tools-version: 6.2.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClockFace",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "ClockFace",
            targets: ["ClockFace"],
        ),
    ],
    dependencies: [
        .package(path: "../DesignToken"),
    ],
    targets: [
        .target(
            name: "ClockFace",
            dependencies: [
                .product(name: "DesignToken", package: "DesignToken"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

