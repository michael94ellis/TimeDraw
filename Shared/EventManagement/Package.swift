// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EventManagement",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "EventManagement",
            targets: ["EventManagement"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
    ],
    targets: [
        .target(
            name: "EventManagement",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
