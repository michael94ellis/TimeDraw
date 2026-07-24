// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EventInput",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "EventInput",
            targets: ["EventInput"]
        ),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../DesignToken"),
        .package(path: "../UIComponents"),
        .package(path: "../EventUIComponents"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
        .package(url: "https://github.com/michael94ellis/ToastWindow", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "EventInput",
            dependencies: [
                .product(name: "AppCore", package: "AppCore"),
                .product(name: "DesignToken", package: "DesignToken"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "EventUIComponents", package: "EventUIComponents"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "ToastWindow", package: "ToastWindow"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
