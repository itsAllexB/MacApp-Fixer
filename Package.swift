// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacAppFixer",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "MacAppFixer", targets: ["MacAppFixer"])
    ],
    targets: [
        .executableTarget(
            name: "MacAppFixer",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
