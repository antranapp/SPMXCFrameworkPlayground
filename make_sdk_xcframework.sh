#!/bin/sh

# To exit the script as soon as one of the commands failed
set -e

# Clean old build
rm -rf ./.build/SDK.xcframework

set -o pipefail && xcodebuild clean archive \
 -scheme SDK \
 -configuration Release \
 -destination "generic/platform=iOS Simulator" \
 -archivePath ./.build/SDK-iphonesimulator \
 -sdk iphonesimulator \
 -derivedDataPath ./.derivedData \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcbeautify

mkdir -p ./.build/SDK-iphonesimulator.xcarchive/Products/Library/Frameworks/SDK.framework/Modules

cp -rf ./.derivedData/Build/Intermediates.noindex/ArchiveIntermediates/SDK/BuildProductsPath/Release-iphonesimulator/SDK.swiftmodule ./.build/SDK-iphonesimulator.xcarchive/Products/Library/Frameworks/SDK.framework/Modules

set -o pipefail && xcodebuild archive \
 -scheme SDK \
 -configuration Release \
 -destination "generic/platform=iOS" \
 -archivePath ./.build/SDK-iphoneos \
 -sdk iphoneos \
 -derivedDataPath ./.derivedData \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcbeautify

mkdir -p ./.build/SDK-iphoneos.xcarchive/Products/Library/Frameworks/SDK.framework/Modules

cp -rf ./.derivedData/Build/Intermediates.noindex/ArchiveIntermediates/SDK/BuildProductsPath/Release-iphoneos/SDK.swiftmodule ./.build/SDK-iphoneos.xcarchive/Products/Library/Frameworks/SDK.framework/Modules

xcodebuild -create-xcframework -framework ./.build/SDK-iphoneos.xcarchive/Products/Library/Frameworks/SDK.framework -framework ./.build/SDK-iphonesimulator.xcarchive/Products/Library/Frameworks/SDK.framework -output ./.build/SDK.xcframework