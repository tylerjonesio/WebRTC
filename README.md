# WebRTC Binaries for iOS, macOS and tvOS
[![Latest version](https://img.shields.io/github/v/release/tylerjonesio/webrtc)](https://github.com/tylerjonesio/WebRTC/releases)
[![Release Date](https://img.shields.io/github/release-date/tylerjonesio/webrtc)](https://github.com/tylerjonesio/WebRTC/releases)
[![Total Downloads](https://img.shields.io/github/downloads/tylerjonesio/webrtc/total)](https://github.com/tylerjonesio/WebRTC/releases)


This repository contains unofficial distribution of WebRTC framework binaries for iOS, macOS and tvOS.

Since version M80, Google has [deprecated](https://groups.google.com/g/discuss-webrtc/c/Ozvbd0p7Q1Y/m/M4WN2cRKCwAJ?pli=1) their mobile binary libraries distributions (Was officially using the [GoogleWebRTC pod](https://cocoapods.org/pods/GoogleWebRTC)). To get the most up to date WebRTC library, you can compile it on your own, or you can use precompiled binaries from here or other sources.

## 📦 Releases
The binary releases correspond with official Chromium releases and branches as specified in the [Chromium dashboard](https://chromiumdash.appspot.com/branches).

## 💡 Things to know
* All binaries in this repository are compiled from the official WebRTC [source code](https://webrtc.googlesource.com/src/).
* Certain patches have been applied to ensure proper compilation for all of the included platforms. They can be found in the `patches/` directory.
* Dynamic framework (xcframework format) which contains multiple binaries for macOS, iOS, and tvOS.

## 📢 Requirements
* iOS 12+
* macOS 10.11+
* macOS Catalyst 11.0+
* tvOS 12+

## 📀 Binaries included
| **Platform / arch**  | arm64  | x86_x64 |
|----------------------|--------|---------|
| **iOS (device)**     |   ✅   |   N/A   |
| **iOS (simulator)**  |   ✅   |    ✅   |
| **macOS**            |   ✅   |    ✅   |
| **macOS Catalyst**   |   ✅   |    ✅   | 
| **tvOS (device)**    |   ✅   |   N/A   | 
| **tvOS (simulator)** |   ✅   |    ⛔️   | 

## 🚚 Installation

### Swift package manager
Xcode has a built-in support for Swift package manager. You can easily add the package by selecting File > Swift Packages > Add Package Dependency. Read more in [Apple documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

Or, you can add the following dependency to your `Package.swift` file:
```swift
dependencies: [
    .package(url: "https://github.com/tylerjonesio/WebRTC.git", .upToNextMajor("117.0.0"))
]
```

Use the `latest` branch to get the most up to date binary:

```swift
dependencies: [
    .package(url: "https://github.com/tylerjonesio/WebRTC.git", branch: "latest")
]
```

### Manual
1. Download the framework from the [releases](https://github.com/tylerjonesio/WebRTC/releases) section.
2. Unzip the file.
3. Add the xcframework to your target(s) embedded frameworks.


## 👷 Usage
To import WebRTC to your code add the following import statement
```swift
import WebRTC
```

If you wish to see how to use WebRTC I highly recommend checking out the upstream WebRTC demo iOS app: https://github.com/stasel/WebRTC-iOS


## 🛠 Compile your own WebRTC Frameworks
If you wish to compile your own WebRTC binary framework, please refer to the following official guide:
https://webrtc.googlesource.com/src/+/refs/heads/main/docs/native-code/ios/README.md

You can also take a look at the [build script](scripts/build.sh) I created for more details.

## 📃 License
* BSD 3-Clause License
* WebRTC License: https://webrtc.org/support/license
