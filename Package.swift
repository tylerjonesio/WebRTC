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
            url: "https://github.com/tylerjonesio/WebRTC/releases/download/153.0.1/WebRTC-2026-09-29T16-11-03.xcframework.zip",
            checksum: "cc10882c31d4d5077da230f435fde55615757fda0557d5ccd2bedf8c901228c5"
        ),
    ]
)
