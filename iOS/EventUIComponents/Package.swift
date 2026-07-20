// swift-tools-version: 6.2.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EventUIComponents",
    platforms: [
        .iOS(.v16) // Restricts the package to iOS 16 and later
    ],
    products: [
        .library(
            name: "EventUIComponents",
            targets: ["EventUIComponents"]
        ),
    ],
    targets: [
        .target(
            name: "EventUIComponents"
        ),

    ],
    swiftLanguageModes: [.v6]
)
