// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignToken",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "DesignToken",
            targets: ["DesignToken"]
        ),
    ],
    targets: [
        .target(
            name: "DesignToken",
            resources: [
                .copy("Default/Fonts/Inter-Black.ttf"),
                .copy("Default/Fonts/Inter-Bold.ttf"),
                .copy("Default/Fonts/Inter-ExtraBold.ttf"),
                .copy("Default/Fonts/Inter-ExtraLight.ttf"),
                .copy("Default/Fonts/Inter-Light.ttf"),
                .copy("Default/Fonts/Inter-Medium.ttf"),
                .copy("Default/Fonts/Inter-Regular.ttf"),
                .copy("Default/Fonts/Inter-SemiBold.ttf"),
                .copy("Default/Fonts/Inter-Thin.ttf"),
            ]
        ),
    ]
)
