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
        .library(name: "MetalRenderKit", targets: ["MetalRenderKit"]),
        .library(name: "CoreAnimationLab", targets: ["CoreAnimationLab"]),
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
        .target(
            name: "MetalRenderKit",
            dependencies: ["RenderLabCore"],
            path: "Packages/MetalRenderKit",
            resources: [.process("Shaders")]
        ),
        .target(
            name: "CoreAnimationLab",
            dependencies: ["RenderLabCore"],
            path: "Packages/CoreAnimationLab"
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
        .testTarget(
            name: "MetalRenderKitTests",
            dependencies: ["MetalRenderKit"],
            path: "Packages/MetalRenderKitTests"
        ),
        .testTarget(
            name: "CoreAnimationLabTests",
            dependencies: ["CoreAnimationLab"],
            path: "Packages/CoreAnimationLabTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
