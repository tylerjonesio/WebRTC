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
            url: "https://github.com/tylerjonesio/WebRTC/releases/download/137.0.0/WebRTC-2025-06-30T18-26-06.xcframework.zip",
            checksum: "c1cc85be01a87b4cc476a5212eafa6aca916b5dc40047f5ec289d0fe803bd89c"
        ),
    ]
)
