#!/bin/bash
# This script builds the universal MisfitCloudAPI.framework. Please find the output framework in "RELEASE" directory.
# set -e
if [ -z "$1" ]
  then
  echo "ERROR: Please specify build configuration. It must be either 'Release' or 'Debug'"
  echo "Run me with: sh build_framework.sh [build_configuration]"
  exit 1
fi

#cd MisfitCloudAPIWrapper_iOS

# Mandatory fields, assign values from the target's build settings
MF_PRODUCT_NAME="MisfitCloudAPI"
MF_WORKSPACE_PATH="MisfitCloudAPI.xcworkspace"
MF_BUILD_SCHEME="MisfitCloudAPI"
MF_BUILD_CONFIGURATION="$1"
MF_PUBLIC_HEADERS_FOLDER_PATH="include/${MF_PRODUCT_NAME}"

# Optional
MF_FRAMEWORK_PATH="${MF_PRODUCT_NAME}.framework"
MF_STATIC_LIB_PATH="lib${MF_PRODUCT_NAME}.a"
MF_BUILD_DIR="$(pwd)/RELEASE"

# build library for iphoneos
xcodebuild -workspace "${MF_WORKSPACE_PATH}" \
           -scheme "${MF_BUILD_SCHEME}" \
           -configuration "${MF_BUILD_CONFIGURATION}" \
           -sdk iphoneos \
           ONLY_ACTIVE_ARCH=NO CLANG_MODULES_AUTOLINK=NO \
           CONFIGURATION_BUILD_DIR="${MF_BUILD_DIR}" clean build

if [[ $? != 0 ]]; then
    mv "MisfitCloudAPI/MisfitCloudAPI.h.org" "MisfitCloudAPI/MisfitCloudAPI.h"
    exit 1
fi
mv "${MF_BUILD_DIR}/${MF_STATIC_LIB_PATH}" "${MF_BUILD_DIR}/lib${MF_PRODUCT_NAME}-realDevice.a"

# build library for iphoneos
xcodebuild -workspace "${MF_WORKSPACE_PATH}" \
           -scheme "${MF_BUILD_SCHEME}" \
           -configuration "${MF_BUILD_CONFIGURATION}" \
           -sdk iphonesimulator \
           ONLY_ACTIVE_ARCH=NO CLANG_MODULES_AUTOLINK=NO \
           CONFIGURATION_BUILD_DIR="${MF_BUILD_DIR}" clean build

if [[ $? != 0 ]]; then
    mv "MisfitCloudAPI/MisfitCloudAPI.h.org" "MisfitCloudAPI/MisfitCloudAPI.h"
    exit 1
fi
mv "${MF_BUILD_DIR}/${MF_STATIC_LIB_PATH}" "${MF_BUILD_DIR}/lib${MF_PRODUCT_NAME}-simulator.a"

# Smash the two static libraries into one fat binary and store it in the .framework
xcrun lipo -create -output "${MF_BUILD_DIR}/${MF_STATIC_LIB_PATH}" "${MF_BUILD_DIR}/lib${MF_PRODUCT_NAME}-realDevice.a" "${MF_BUILD_DIR}/lib${MF_PRODUCT_NAME}-simulator.a"

# PREPARE FRAMEWORK
# clean up previous build product
rm -rf "${MF_BUILD_DIR}/${MF_FRAMEWORK_PATH}"
mkdir -p "${MF_BUILD_DIR}/${MF_FRAMEWORK_PATH}/Versions/A/Headers"

# Link the "Current" version to "A"
/bin/ln -sfh A "${MF_BUILD_DIR}/${MF_FRAMEWORK_PATH}/Versions/Current"
/bin/ln -sfh Versions/Current/Headers "${MF_BUILD_DIR}/${MF_FRAMEWORK_PATH}/Headers"
/bin/ln -sfh "Versions/Current/${MF_PRODUCT_NAME}" "${MF_BUILD_DIR}/${MF_FRAMEWORK_PATH}/${MF_PRODUCT_NAME}"

# The -a ensures that the headers maintain the source modification date so that we don't constantly
# cause propagating rebuilds of files that import these headers.
/bin/cp -a "${MF_BUILD_DIR}/${MF_PUBLIC_HEADERS_FOLDER_PATH}/" "${MF_BUILD_DIR}/${MF_FRAMEWORK_PATH}/Versions/A/Headers"

# move the universal library in the framework.
/bin/mv "${MF_BUILD_DIR}/${MF_STATIC_LIB_PATH}" "${MF_BUILD_DIR}/${MF_FRAMEWORK_PATH}/Versions/A/${MF_PRODUCT_NAME}"

# Clean up temporary files
rm -rf "${MF_BUILD_DIR}/lib${MF_PRODUCT_NAME}-realDevice.a"
rm -rf "${MF_BUILD_DIR}/lib${MF_PRODUCT_NAME}-simulator.a"
rm -rf "${MF_BUILD_DIR}/${MF_PUBLIC_HEADERS_FOLDER_PATH}/"
rm -rf "${MF_BUILD_DIR}"/libPods*
find "${MF_BUILD_DIR}" -empty -type d -delete
