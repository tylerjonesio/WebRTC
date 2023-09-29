#!/bin/bash

GN_OUT_PATH=$1
echo "Performing fixes to build tvOS..."

ninjas=`find ${GN_OUT_PATH} -name '*.ninja'`
ninjas=$(echo "$ninjas" | tr ' ' '\n' | sort -u | tr '\n' ' ')

for ninja in $ninjas; do
    sed -i -- "s/iphoneos-version/appletvos-version/g" $ninja
    sed -i -- "s/arm64-apple-ios/arm64-apple-tvos/g" $ninja
    sed -i -- "s/x86_64-apple-ios/x86_64-apple-tvos/g" $ninja
    sed -i -- "s/swift\/iphonesimulator/swift\/appletvsimulator/g" $ninja
    sed -i -- "s/iphoneos/appletvos/g" $ninja
    sed -i -- "s/iphonesimulator/appletvsimulator/g" $ninja
    sed -i -- "s/iPhoneOS/AppleTVOS/g" $ninja
    sed -i -- "s/iPhoneSimulator/AppleTVSimulator/g" $ninja
done
