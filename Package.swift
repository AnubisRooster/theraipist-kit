// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "therAIpist-kit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "BYOKLLMKit", targets: ["BYOKLLMKit"]),
        .library(name: "VoiceLoopKit", targets: ["VoiceLoopKit"]),
    ],
    targets: [
        .target(name: "BYOKLLMKit"),
        .testTarget(name: "BYOKLLMKitTests", dependencies: ["BYOKLLMKit"]),

        .target(name: "VoiceLoopKit"),
        .testTarget(name: "VoiceLoopKitTests", dependencies: ["VoiceLoopKit"]),
    ]
)
