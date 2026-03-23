// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SSG",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "SSG", targets: ["SSG"]),
        .library(name: "SSGCore", targets: ["SSGCore"]),
    ],
    targets: [
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
            name: "SSGCoreTests",
            dependencies: ["SSGCore"],
            path: "Tests/SSGCoreTests",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
