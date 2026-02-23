// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HologramKit",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "HologramKit", targets: ["HologramKit"])
    ],
    targets: [
        .target(
            name: "HologramKit",
            resources: [
                .process("Shaders")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "HologramKitTests",
            dependencies: ["HologramKit"]
        )
    ]
)
