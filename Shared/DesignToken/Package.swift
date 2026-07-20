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
                .copy("Fonts/Inter-Black.ttf"),
                .copy("Fonts/Inter-Bold.ttf"),
                .copy("Fonts/Inter-ExtraBold.ttf"),
                .copy("Fonts/Inter-ExtraLight.ttf"),
                .copy("Fonts/Inter-Light.ttf"),
                .copy("Fonts/Inter-Medium.ttf"),
                .copy("Fonts/Inter-Regular.ttf"),
                .copy("Fonts/Inter-SemiBold.ttf"),
                .copy("Fonts/Inter-Thin.ttf"),
            ]
        ),
    ]
)
