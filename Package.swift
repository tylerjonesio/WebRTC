// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "WebRTC",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v17)],
    products: [
        .library(
            name: "WebRTC",
            targets: ["WebRTC"]),
    ],
    dependencies: [ ],
    targets: [
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/tylerjonesio/WebRTC/releases/download/133.0.0.b1/WebRTC-2025-02-23T01-26-30.xcframework.zip",
            checksum: "c65875394aadcf5183350d908284aa641e870ebe4da6d95d5e01d6d3a05fd311"
        ),
    ]
)
