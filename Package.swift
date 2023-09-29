// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "WebRTC",
    platforms: [.iOS(.v12), .macOS(.v10_11), .tvOS(.v12)],
    products: [
        .library(
            name: "WebRTC",
            targets: ["WebRTC"]),
    ],
    dependencies: [ ],
    targets: [
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/tylerjonesio/WebRTC/releases/download/117.0.0.b2/WebRTC-2023-09-29T22-53-51.xcframework.zip",
            checksum: "3bc1a7a6b8301f14e81e57751d331a816c77d3e98855ab902ac714258ea00dcc"
        ),
    ]
)
