// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MetalAnimationLab",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "RenderLabCore", targets: ["RenderLabCore"]),
        .library(name: "AnimationPlayground", targets: ["AnimationPlayground"]),
    ],
    targets: [
        .target(
            name: "RenderLabCore",
            path: "Packages/RenderLabCore"
        ),
        .target(
            name: "AnimationPlayground",
            path: "Packages/AnimationPlayground"
        ),
        .testTarget(
            name: "RenderLabCoreTests",
            dependencies: ["RenderLabCore"],
            path: "Packages/RenderLabCoreTests"
        ),
        .testTarget(
            name: "AnimationPlaygroundTests",
            dependencies: ["AnimationPlayground"],
            path: "Packages/AnimationPlaygroundTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

