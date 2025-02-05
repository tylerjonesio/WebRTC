#!/bin/sh

## WebRTC library build script
## Created by Stasel
## BSD-3 License
## 
## Example usage: MACOS=true IOS=true BUILD_VP9=true sh build.sh

# Configs
DEBUG="${DEBUG:-false}"
BUILD_VP9="${BUILD_VP9:-false}"
BRANCH="${BRANCH:-master}"
IOS="${IOS:-false}"
TVOS="${TVOS:-false}"
MACOS="${MACOS:-false}"
MAC_CATALYST="${MAC_CATALYST:-false}"

OUTPUT_DIR="./out"
XCFRAMEWORK_DIR="out/WebRTC.xcframework"
COMMON_GN_ARGS="is_debug=${DEBUG} rtc_libvpx_build_vp9=${BUILD_VP9} is_component_build=false rtc_include_tests=false rtc_enable_objc_symbol_export=true enable_stripping=true enable_dsyms=false use_lld=true rtc_exclude_audio_processing_module=true rtc_include_internal_audio_device=false"
PLISTBUDDY_EXEC="/usr/libexec/PlistBuddy"

build_iOS() {
    local arch=$1
    local environment=$2
    local gen_dir="${OUTPUT_DIR}/ios-${arch}-${environment}"
    local gen_args="${COMMON_GN_ARGS} target_cpu=\"${arch}\" target_os=\"ios\" target_environment=\"${environment}\" ios_deployment_target=\"12.0\" ios_enable_code_signing=false"
    gn gen "${gen_dir}" --args="${gen_args}"
    ninja -C "${gen_dir}" framework_objc || exit 1
}

build_tvOS() {
    local arch=$1
    local environment=$2
    local gen_dir="${OUTPUT_DIR}/tvos-${arch}-${environment}"
    
    if [ "$environment" = "simulator" ]; then
        ios_sdk_name="appletvsimulator"
        ios_sdk_platform="AppleTVSimulator"
    else
        ios_sdk_name="appletvos"
        ios_sdk_platform="AppleTVOS"
    fi
    
    SDK_INFO="./build/config/apple/sdk_info.py --get_sdk_info --get_machine_info "${ios_sdk_name}""
    local ios_platform_build=$(eval $SDK_INFO | grep "sdk_build" | awk -F'[=]' '{print $2}')
    local ios_sdk_path=$(eval $SDK_INFO | grep "sdk_path" | awk -F'[=]' '{print $2}')
    local ios_sdk_build=$(eval $SDK_INFO | grep "sdk_build" | awk -F'[=]' '{print $2}')
    local ios_sdk_platform_path=$(eval $SDK_INFO | grep "sdk_platform_path" | awk -F'[=]' '{print $2}')
    local ios_sdk_version=$(eval $SDK_INFO | grep "sdk_version" | awk -F'[=]' '{print $2}')
    local ios_toolchains_path=$(eval $SDK_INFO | grep "toolchains_path" | awk -F'[=]' '{print $2}')
    local ios_bin_path="$(echo $ios_toolchains_path | tr -d '"')/usr/bin/"
    local xcode_version=$(eval $SDK_INFO | grep "xcode_version=" | awk -F'[=]' '{print $2}')
    local xcode_version_int=$(eval $SDK_INFO | grep "xcode_version_int" | awk -F'[=]' '{print $2}')
    local xcode_build=$(eval $SDK_INFO | grep "xcode_build" | awk -F'[=]' '{print $2}')
    local machine_os_build=$(eval $SDK_INFO | grep "machine_os_build" | awk -F'[=]' '{print $2}')

    if [ "$environment" = "simulator" ]; then
        ios_platform_build="\"\""
    fi
    
    local target_args="target_cpu=\"${arch}\" target_os=\"ios\" target_environment=\"${environment}\""
    local sdk_args="ios_sdk_path=${ios_sdk_path} ios_sdk_name=\"${ios_sdk_name}\" ios_sdk_platform=\"${ios_sdk_platform}\" ios_sdk_build=${ios_sdk_build} ios_sdk_platform_path=${ios_sdk_platform_path} ios_sdk_version=${ios_sdk_version} ios_toolchains_path=${ios_toolchains_path} ios_bin_path=\"${ios_bin_path}\" ios_platform_build=${ios_platform_build}"
    local xcode_args="xcode_version=${xcode_version} xcode_version_int=${xcode_version_int} xcode_build=${xcode_build} machine_os_build=${machine_os_build}"
    local gen_args="${COMMON_GN_ARGS} ${target_args} ${sdk_args} ${xcode_args} ios_deployment_target=\"12.0\" ios_enable_code_signing=false"
    
    gn gen "${gen_dir}" --args="${gen_args}"
    
    # Provide fixups for everything that couldn't be set by the above variables
    ../scripts/fix-tvos.sh "${OUTPUT_DIR}/tvos-${arch}-${environment}"
    
    ninja -C "${gen_dir}" framework_objc || exit 1
}

build_macOS() {
    local arch=$1
    local gen_dir="${OUTPUT_DIR}/macos-${arch}"
    local gen_args="${COMMON_GN_ARGS} target_cpu=\"${arch}\" target_os=\"mac\""
    gn gen "${gen_dir}" --args="${gen_args}"
    ninja -C "${gen_dir}" mac_framework_objc || exit 1
}

# Catalyst builds are not working properly yet. 
# See: https://groups.google.com/g/discuss-webrtc/c/VZXS4V4mSY4
build_catalyst() {
    local arch=$1
    local gen_dir="${OUTPUT_DIR}/catalyst-${arch}"
    local gen_args="${COMMON_GN_ARGS} target_cpu=\"${arch}\" target_environment=\"catalyst\" target_os=\"ios\" ios_deployment_target=\"14.0\" ios_enable_code_signing=false"
    gn gen "${gen_dir}" --args="${gen_args}"
    ninja -C "${gen_dir}" framework_objc || exit 1
}

plist_add_library() {
    local index=$1
    local identifier=$2
    local platform=$3
    local platform_variant=$4
    "$PLISTBUDDY_EXEC" -c "Add :AvailableLibraries: dict"  "${INFO_PLIST}"
    "$PLISTBUDDY_EXEC" -c "Add :AvailableLibraries:${index}:LibraryIdentifier string ${identifier}"  "${INFO_PLIST}"
    "$PLISTBUDDY_EXEC" -c "Add :AvailableLibraries:${index}:LibraryPath string WebRTC.framework"  "${INFO_PLIST}"
    "$PLISTBUDDY_EXEC" -c "Add :AvailableLibraries:${index}:SupportedArchitectures array"  "${INFO_PLIST}"
    "$PLISTBUDDY_EXEC" -c "Add :AvailableLibraries:${index}:SupportedPlatform string ${platform}"  "${INFO_PLIST}"
    if [ ! -z "$platform_variant" ]; then
        "$PLISTBUDDY_EXEC" -c "Add :AvailableLibraries:${index}:SupportedPlatformVariant string ${platform_variant}" "${INFO_PLIST}"
    fi
}

plist_add_architecture() {
    local index=$1
    local arch=$2
    "$PLISTBUDDY_EXEC" -c "Add :AvailableLibraries:${index}:SupportedArchitectures: string ${arch}"  "${INFO_PLIST}"
}

# Step 1: Download and install depot tools
if [ ! -d depot_tools ]; then
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
else
    cd depot_tools
    git pull origin main
    cd ..
fi
export PATH=$(pwd)/depot_tools:$PATH

# Step 2 - Download and build WebRTC
if [ ! -d src ]; then
    fetch --nohooks webrtc_ios
fi
cd src
git stash
git fetch --all
git checkout $BRANCH
for filename in ../patches/*.patch; do
    echo "Applying patch $filename..."
    git apply $filename
done

cd ..
gclient sync --with_branch_heads --with_tags
cd src

# Step 2.5 - Apply patches (Temp)
# sed -i '' 's/"-mllvm",$/# "-mllvm",/g' ./build/config/compiler/BUILD.gn
# sed -i '' 's/"-instcombine-lower-dbg-declare=0",$/# "-instcombine-lower-dbg-declare=0",/g' ./build/config/compiler/BUILD.gn

# Step 3 - Compile and build all frameworks
rm -rf $OUTPUT_DIR  

if [ "$IOS" = true ]; then
    build_iOS "x64" "simulator"
    build_iOS "arm64" "simulator"
    build_iOS "arm64" "device"
fi

if [ "$TVOS" = true ]; then
#    build_tvOS "x64" "simulator"
    build_tvOS "arm64" "simulator"
    build_tvOS "arm64" "device"
fi

if [ "$MACOS" = true ]; then
    build_macOS "x64"
    build_macOS "arm64"
fi

if [ "$MAC_CATALYST" = true ]; then
    build_catalyst "x64"
    build_catalyst "arm64"
fi

# Step 4 - Manually create XCFramework.
# Unfortunately we cannot use xcodebuild `-xcodebuild -create-xcframework` because of an error:
# "Both ios-arm64-simulator and ios-x86_64-simulator represent two equivalent library definitions."
# Therefore, we craft the XCFramework manually with multi architecture binaries created by lipo.
# We also use plistbuddy to create the plist for the XCFramework

INFO_PLIST="${XCFRAMEWORK_DIR}/Info.plist"
rm -rf "${XCFRAMEWORK_DIR}"
mkdir "${XCFRAMEWORK_DIR}"
"$PLISTBUDDY_EXEC" -c "Add :CFBundlePackageType string XFWK"  "${INFO_PLIST}"
"$PLISTBUDDY_EXEC" -c "Add :XCFrameworkFormatVersion string 1.0"  "${INFO_PLIST}"
"$PLISTBUDDY_EXEC" -c "Add :AvailableLibraries array" "${INFO_PLIST}"

# Step 5.1 - Add iOS libs to XCFramework
LIB_COUNT=0
if [[ "$IOS" = true ]]; then

    IOS_LIB_IDENTIFIER="ios-arm64"
    IOS_SIM_LIB_IDENTIFIER="ios-x86_64_arm64-simulator"

    mkdir "${XCFRAMEWORK_DIR}/${IOS_LIB_IDENTIFIER}"
    mkdir "${XCFRAMEWORK_DIR}/${IOS_SIM_LIB_IDENTIFIER}"
    LIB_IOS_INDEX=0
    LIB_IOS_SIMULATOR_INDEX=1
    plist_add_library $LIB_IOS_INDEX $IOS_LIB_IDENTIFIER "ios"
    plist_add_library $LIB_IOS_SIMULATOR_INDEX $IOS_SIM_LIB_IDENTIFIER "ios" "simulator"

    cp -r out/ios-arm64-device/WebRTC.framework "${XCFRAMEWORK_DIR}/${IOS_LIB_IDENTIFIER}"
    cp -r out/ios-x64-simulator/WebRTC.framework "${XCFRAMEWORK_DIR}/${IOS_SIM_LIB_IDENTIFIER}"

    LIPO_IOS_FLAGS="out/ios-arm64-device/WebRTC.framework/WebRTC"
    LIPO_IOS_SIM_FLAGS="out/ios-x64-simulator/WebRTC.framework/WebRTC out/ios-arm64-simulator/WebRTC.framework/WebRTC"

    plist_add_architecture $LIB_IOS_INDEX "arm64"
    plist_add_architecture $LIB_IOS_SIMULATOR_INDEX "arm64"
    plist_add_architecture $LIB_IOS_SIMULATOR_INDEX "x86_64"

    lipo -create -output  "${XCFRAMEWORK_DIR}/${IOS_LIB_IDENTIFIER}/WebRTC.framework/WebRTC" ${LIPO_IOS_FLAGS}
    lipo -create -output "${XCFRAMEWORK_DIR}/${IOS_SIM_LIB_IDENTIFIER}/WebRTC.framework/WebRTC" ${LIPO_IOS_SIM_FLAGS}

    # codesign simulator framework for local development.
    # This makes it possible for Swift Packages to run Unit Tests and show SwiftUI Previews.
    xcrun codesign -s - "${XCFRAMEWORK_DIR}/${IOS_SIM_LIB_IDENTIFIER}/WebRTC.framework/WebRTC"

    LIB_COUNT=$((LIB_COUNT+2))
fi

# Step 5.2 - Add tvOS libs to XCFramework
if [[ "$TVOS" = true ]]; then

    TVOS_LIB_IDENTIFIER="tvos-arm64"
    TVOS_SIM_LIB_IDENTIFIER="tvos-arm64-simulator"

    mkdir "${XCFRAMEWORK_DIR}/${TVOS_LIB_IDENTIFIER}"
    mkdir "${XCFRAMEWORK_DIR}/${TVOS_SIM_LIB_IDENTIFIER}"
    LIB_TVOS_INDEX=$LIB_COUNT
    LIB_TVOS_SIMULATOR_INDEX=$((LIB_COUNT+1))
    plist_add_library $LIB_TVOS_INDEX $TVOS_LIB_IDENTIFIER "tvos"
    plist_add_library $LIB_TVOS_SIMULATOR_INDEX $TVOS_SIM_LIB_IDENTIFIER "tvos" "simulator"

    cp -r out/tvos-arm64-device/WebRTC.framework "${XCFRAMEWORK_DIR}/${TVOS_LIB_IDENTIFIER}"
    cp -r out/tvos-arm64-simulator/WebRTC.framework "${XCFRAMEWORK_DIR}/${TVOS_SIM_LIB_IDENTIFIER}"

    LIPO_TVOS_FLAGS="out/tvos-arm64-device/WebRTC.framework/WebRTC"
    LIPO_TVOS_SIM_FLAGS="out/tvos-arm64-simulator/WebRTC.framework/WebRTC"

    plist_add_architecture $LIB_TVOS_INDEX "arm64"
    plist_add_architecture $LIB_TVOS_SIMULATOR_INDEX "arm64"
#    plist_add_architecture $LIB_TVOS_SIMULATOR_INDEX "x86_64"

    lipo -create -output  "${XCFRAMEWORK_DIR}/${TVOS_LIB_IDENTIFIER}/WebRTC.framework/WebRTC" ${LIPO_TVOS_FLAGS}
    lipo -create -output "${XCFRAMEWORK_DIR}/${TVOS_SIM_LIB_IDENTIFIER}/WebRTC.framework/WebRTC" ${LIPO_TVOS_SIM_FLAGS}

    # codesign simulator framework for local development.
    # This makes it possible for Swift Packages to run Unit Tests and show SwiftUI Previews.
    xcrun codesign -s - "${XCFRAMEWORK_DIR}/${TVOS_SIM_LIB_IDENTIFIER}/WebRTC.framework/WebRTC"

    LIB_COUNT=$((LIB_COUNT+2))
fi

# Step 5.3 - Add macOS libs to XCFramework
if [ "$MACOS" = true ]; then

    MAC_LIB_IDENTIFIER="macos-x86_64_arm64"

    mkdir "${XCFRAMEWORK_DIR}/${MAC_LIB_IDENTIFIER}"
    plist_add_library $LIB_COUNT "${MAC_LIB_IDENTIFIER}" "macos"
    plist_add_architecture $LIB_COUNT "x86_64"
    plist_add_architecture $LIB_COUNT "arm64"

    cp -RP out/macos-x64/WebRTC.framework "${XCFRAMEWORK_DIR}/${MAC_LIB_IDENTIFIER}"
    lipo -create -output "${XCFRAMEWORK_DIR}/${MAC_LIB_IDENTIFIER}/WebRTC.framework/Versions/A/WebRTC" out/macos-x64/WebRTC.framework/WebRTC out/macos-arm64/WebRTC.framework/WebRTC
    LIB_COUNT=$((LIB_COUNT+1))
fi

# Step 5.4 - macOS catalyst libs to XCFramework
if [ "$MAC_CATALYST" = true ]; then

    CATALYST_LIB_IDENTIFIER="ios-x86_64_arm64-maccatalyst"

    mkdir "${XCFRAMEWORK_DIR}/${CATALYST_LIB_IDENTIFIER}"
    plist_add_library $LIB_COUNT "${CATALYST_LIB_IDENTIFIER}" "ios" "maccatalyst"
    plist_add_architecture $LIB_COUNT "x86_64"
    plist_add_architecture $LIB_COUNT "arm64"

    cp -RP out/catalyst-x64/WebRTC.framework "${XCFRAMEWORK_DIR}/${CATALYST_LIB_IDENTIFIER}"
    lipo -create -output "${XCFRAMEWORK_DIR}/${CATALYST_LIB_IDENTIFIER}/WebRTC.framework/Versions/A/WebRTC" out/catalyst-x64/WebRTC.framework/WebRTC out/catalyst-arm64/WebRTC.framework/WebRTC
    LIB_COUNT=$((LIB_COUNT+1))
fi

# Step 6 - Add license file to the framework
cp LICENSE ${XCFRAMEWORK_DIR}

# Step 7 - archive the framework
cd out
NOW=$(date -u +"%Y-%m-%dT%H-%M-%S")
OUTPUT_NAME=WebRTC-$NOW.xcframework.zip
zip --symlinks -r $OUTPUT_NAME WebRTC.xcframework/

# Step 8 calculate SHA256 checksum
CHECKSUM=$(shasum -a 256 $OUTPUT_NAME | awk '{ print $1 }')
COMMIT_HASH=$(git rev-parse HEAD)

echo "{ \"file\": \"${OUTPUT_NAME}\", \"checksum\": \"${CHECKSUM}\", \"commit\": \"${COMMIT_HASH}\", \"branch\": \"${BRANCH}\" }" > metadata.json
cat metadata.json

