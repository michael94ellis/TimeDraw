// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]
        ),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../DesignToken"),
        .package(path: "../EventInput"),
        .package(path: "../DailyGoalTextfield"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                .product(name: "AppCore", package: "AppCore"),
                .product(name: "DesignToken", package: "DesignToken"),
                .product(name: "EventInput", package: "EventInput"),
                .product(name: "DailyGoalTextfield", package: "DailyGoalTextfield"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
