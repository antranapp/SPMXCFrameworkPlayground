#!/bin/bash

# https://medium.com/@german.velibekov_7849/how-to-create-ios-fat-frameworks-libraries-and-thin-c20c2f7e00f0

set -o pipefail
set -e

usage="
$(basename "$0") [-h] [-w workspace] [-c configuration] [-o output]
Create fat frameworks from the list provided as a last parameter.
	-h show the help text
	-w path to workspace containing xcworkspace format
	-o path to output directory to place a result
	-c scheme configuration
"

while getopts w:o:c:h ARG
do
    case $ARG in
    	w) WORKSPACE=$OPTARG ;;
        o) FAT_DIR=$OPTARG ;;
        c) CONFIGURATION=$OPTARG ;;
        h) echo "$usage"
        exit ;;
    esac
done

# make sure the output directory exists
mkdir -p "${FAT_DIR}"

BUILD_DIR=./.build

sdk=iphoneos
dataPath=$BUILD_DIR/$sdk

simulatorSdk=iphonesimulator
simulatorDataPath=$BUILD_DIR/$simulatorSdk

buildFramework() {
    local scheme=$1
    local framework=$1

    xcodebuild -quiet \
    BITCODE_GENERATION_MODE=bitcode \
    OTHER_CFLAGS="-fembed-bitcode" \
    -project "$WORKSPACE" \
    -scheme "$scheme" \
    ONLY_ACTIVE_ARCH=NO \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "${dataPath}/${framework}" \
    -sdk "$sdk" \
    clean build

    xcodebuild -quiet \
    BITCODE_GENERATION_MODE=bitcode \
    OTHER_CFLAGS="-fembed-bitcode" \
    -project "$WORKSPACE" \
    -scheme "$scheme" \
    ONLY_ACTIVE_ARCH=NO \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "${simulatorDataPath}/${framework}" \
    -sdk "$simulatorSdk" \
    clean build
}

createFatFramework() {
    local frameworkName=$1
    local frameworkWithFormat=$1.framework
    local deviceFramework=$2
    local simFramework=$3
    local outputDir=$4
    

    # create fat binary
    lipo \
    -create $simFramework/$frameworkName $deviceFramework/$frameworkName \
    -output $outputDir/$frameworkName

    # prepare fat-framework
    [ -d $outputDir/$frameworkWithFormat ] && rm -r $outputDir/$frameworkWithFormat
    cp -r $deviceFramework $outputDir

    # replace an original binary with just created one
    rsync --remove-source-files -azv $outputDir/$frameworkName $outputDir/$frameworkWithFormat

    # update Info.plist
    /usr/libexec/PlistBuddy -c "Add :CFBundleSupportedPlatforms: string iPhoneSimulator" "${outputDir}/${frameworkWithFormat}/Info.plist"

    # copy simulator architectures
    cp -R $simFramework/Modules/$frameworkName.swiftmodule/. $outputDir/$frameworkWithFormat/Modules/$frameworkName.swiftmodule/
}

shift 6

while (( "$#" ));
do
	framework=$1
	echo "*** Building ${framework}... ***"
	buildFramework ${framework}
	echo "*** BUILD ${framework} SUCCESS ***"

	echo "*** Creating fat-framework ${framework}... ***"
	deviceFramework=$dataPath/${framework}/Build/Products/$CONFIGURATION-$sdk/${framework}.framework
	simFramework=$simulatorDataPath/${framework}/Build/Products/$CONFIGURATION-$simulatorSdk/${framework}.framework

	createFatFramework "${framework}" "${deviceFramework}" "${simFramework}" "${FAT_DIR}"
	echo "*** Creating fat-framework ${framework} SUCCESS ***"

shift
done