// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NumberFlowSwift",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "NumberFlowSwift",
            targets: ["NumberFlowSwift"]
        ),
    ],
    targets: [
        .target(
            name: "NumberFlowSwift",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "NumberFlowSwiftTests",
            dependencies: ["NumberFlowSwift"]
        ),
    ]
)
