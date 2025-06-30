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
            url: "https://github.com/tylerjonesio/WebRTC/releases/download/137.0.1/WebRTC-2025-06-30T21-21-02.xcframework.zip",
            checksum: "b1c6a6759163c33191d5445d55c55cb2cd8c8496e89de6e3bc59bef993790cf8"
        ),
    ]
)
