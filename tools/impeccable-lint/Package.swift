// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "impeccable-lint",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "impeccable-lint", targets: ["ImpeccableLint"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "510.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ImpeccableLint",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "ImpeccableLintTests",
            dependencies: ["ImpeccableLint"],
            resources: []
        )
    ]
)
