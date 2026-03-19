// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSG",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "SSG", targets: ["SSG"]),
        .library(name: "SSGCore", targets: ["SSGCore"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "SSG",
            dependencies: ["SSGCore"],
            path: "Sources/SSG",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "SSGCore",
            path: "Sources/SSGCore",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "SSGTests",
            dependencies: ["SSGCore"],
            path: "Tests/SSGCoreTests",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
