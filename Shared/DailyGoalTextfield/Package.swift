// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DailyGoalTextfield",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DailyGoalTextfield",
            targets: ["DailyGoalTextfield"]
        ),
    ],
    dependencies: [
        .package(path: "../DesignToken"),
        .package(path: "../UIComponents"),
    ],
    targets: [
        .target(
            name: "DailyGoalTextfield",
            dependencies: [
                .product(name: "DesignToken", package: "DesignToken"),
                .product(name: "UIComponents", package: "UIComponents"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
