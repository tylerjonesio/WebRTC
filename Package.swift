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
            url: "https://github.com/tylerjonesio/WebRTC/releases/download/117.0.0.b3/WebRTC-2023-12-03T21-32-00.xcframework.zip",
            checksum: "d0f52031da4318dc0b1a88e32015523db6c5b51a158affb7ccaa1f2c1234079e"
        ),
    ]
)
