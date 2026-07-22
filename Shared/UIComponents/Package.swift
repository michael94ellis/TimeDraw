// swift-tools-version: 6.2.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "UIComponents",
            targets: ["UIComponents"],
        ),
    ],
    dependencies: [
        .package(path: "../DesignToken"),
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: [
                .product(name: "DesignToken", package: "DesignToken"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
