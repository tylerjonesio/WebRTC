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
            url: "https://github.com/tylerjonesio/WebRTC/releases/download/117.0.0.b1/WebRTC-2023-09-29T22-33-24.xcframework.zip",
            checksum: "5d832f162a0a3159e78e047862b95463c547338a5683754109e6dec5af0e3e42"
        ),
    ]
)
