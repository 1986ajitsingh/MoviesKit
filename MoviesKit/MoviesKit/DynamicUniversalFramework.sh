set -e
set +u

if [[ $SCRIPT_RUNNING ]]
then
exit 0
fi
set -u
export SCRIPT_RUNNING=1

# Environment Variables
TARGET_NAME=${PROJECT_NAME}
OUTPUT_DIR=${PROJECT_DIR}/Release

# Encapsulate Xcode Build Process
function build_dynamic_framework {
    
    xcrun xcodebuild -project "${PROJECT_FILE_PATH}" \
    -target "${PROJECT_NAME}" \
    -configuration "${CONFIGURATION}" \
    -sdk "${1}" \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_DIR="${BUILD_DIR}" \
    OBJROOT="${OBJROOT}" \
    BUILD_ROOT="${BUILD_ROOT}" \
    SYMROOT="${SYMROOT}" $ACTION
    
}

# Encapsulate Lipo
function merge_binaries {
    
    xcrun lipo -create "${1}" "${2}" -output "${3}"
    
}


# 1 - Get SDK to determine platform (iphoneos or iphonesimulator)
if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]; then
SDK_PLATFORM=${BASH_REMATCH[1]}
else
echo "Could not find platform name from SDK_NAME: $SDK_NAME"
exit 1
fi

# 2 - Get Opposite Platform (iphonesimulator --> iphoneos, iphoneos --> iphonesimulator)
if [ "$SDK_PLATFORM" == "iphoneos" ]; then
OTHER_PLATFORM=iphonesimulator
else
OTHER_PLATFORM=iphoneos
fi

# 3 - Get the build directories
CURRENT_DIR=${BUILD_DIR}/${CONFIGURATION}-${SDK_PLATFORM}
OTHER_DIR=${BUILD_DIR}/${CONFIGURATION}-${OTHER_PLATFORM}

# 4 - Build Opposite Platform
build_dynamic_framework "${OTHER_PLATFORM}"

# 5 - Copy Framework Structure
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
cp -R "${BUILD_DIR}/${CONFIGURATION}-${SDK_PLATFORM}/${PROJECT_NAME}.framework" "${OUTPUT_DIR}/${PROJECT_NAME}.framework"

# 6 - Merge Into /Release
merge_binaries "${CURRENT_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${OTHER_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${OUTPUT_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}"
