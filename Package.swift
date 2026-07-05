// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "therAIpist-kit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "BYOKLLMKit", targets: ["BYOKLLMKit"]),
        .library(name: "VoiceLoopKit", targets: ["VoiceLoopKit"]),
        .library(name: "PINLockKit", targets: ["PINLockKit"]),
        .library(name: "ContentSafetyKit", targets: ["ContentSafetyKit"]),
        .library(name: "GraphKit", targets: ["GraphKit"]),
        .library(name: "AgentRouteKit", targets: ["AgentRouteKit"]),
    ],
    targets: [
        .target(name: "BYOKLLMKit"),
        .testTarget(name: "BYOKLLMKitTests", dependencies: ["BYOKLLMKit"]),

        .target(name: "VoiceLoopKit"),
        .testTarget(name: "VoiceLoopKitTests", dependencies: ["VoiceLoopKit"]),

        .target(name: "PINLockKit"),
        .testTarget(name: "PINLockKitTests", dependencies: ["PINLockKit"]),

        .target(name: "ContentSafetyKit"),
        .testTarget(name: "ContentSafetyKitTests", dependencies: ["ContentSafetyKit"]),

        .target(name: "GraphKit"),
        .testTarget(name: "GraphKitTests", dependencies: ["GraphKit"]),

        .target(name: "AgentRouteKit"),
        .testTarget(name: "AgentRouteKitTests", dependencies: ["AgentRouteKit"]),
    ]
)
