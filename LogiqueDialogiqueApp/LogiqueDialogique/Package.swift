// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogiqueDialogique",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LogiqueDialogique",
            targets: ["LogiqueDialogique"]
        ),
    ],
    dependencies: [.package(url: "https://github.com/nicklockwood/Consumer.git", .upToNextMinor(from: "0.3.0"))],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LogiqueDialogique",
            dependencies: [.product(name: "Consumer", package: "Consumer")]
        ),
        .testTarget(
            name: "LogiqueDialogiqueTests",
            dependencies: ["LogiqueDialogique"]
        ),
    ]
)
