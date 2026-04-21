#!/bin/bash
set -euo pipefail

# TaigiTelex PKG Builder
# Builds an unsigned PKG installer for TaigiTelex input method
# Supports universal binary (x86_64 + arm64) for CI builds

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_DIR}/build"
PKG_DIR="${PROJECT_DIR}/pkg"
WORK_DIR="${BUILD_DIR}/pkg_work"
VERSION="${VERSION:-$(cat "${PROJECT_DIR}/VERSION")}"

BUNDLE_ID="com.kahiok.inputmethod.TaigiTelex"
APP_NAME="TaigiTelex"

# Parse command line arguments
UNIVERSAL=false
if [[ "${1:-}" == "--universal" ]]; then
    UNIVERSAL=true
fi

echo "Building TaigiTelex ${VERSION}..."

# Clean up work directory
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

if [[ "$UNIVERSAL" == true ]]; then
    echo "Building universal binary (x86_64 + arm64)..."
    
    # Build for Intel (x86_64)
    echo "Building x86_64..."
    cmake -B "${BUILD_DIR}/x86_64" -G Ninja \
        -DARCH=x86_64 \
        -DCMAKE_BUILD_TYPE=Release \
        "${PROJECT_DIR}"
    cmake --build "${BUILD_DIR}/x86_64"
    
    if [ ! -d "${BUILD_DIR}/x86_64/${APP_NAME}.app" ]; then
        echo "Build failed: ${APP_NAME}.app (x86_64) not found"
        exit 1
    fi
    
    # Build for Apple Silicon (arm64)
    echo "Building arm64..."
    cmake -B "${BUILD_DIR}/arm64" -G Ninja \
        -DARCH=arm64 \
        -DCMAKE_BUILD_TYPE=Release \
        "${PROJECT_DIR}"
    cmake --build "${BUILD_DIR}/arm64"
    
    if [ ! -d "${BUILD_DIR}/arm64/${APP_NAME}.app" ]; then
        echo "Build failed: ${APP_NAME}.app (arm64) not found"
        exit 1
    fi
    
    # Create universal binary using lipo
    echo "Creating universal binary..."
    mkdir -p "${BUILD_DIR}/universal/${APP_NAME}.app/Contents/MacOS"
    
    # Copy app bundle structure from arm64 build (arbitrary choice)
    cp -R "${BUILD_DIR}/arm64/${APP_NAME}.app/Contents" "${BUILD_DIR}/universal/${APP_NAME}.app/"
    
    # Use lipo to combine the two binaries
    lipo -create \
        "${BUILD_DIR}/x86_64/${APP_NAME}.app/Contents/MacOS/${APP_NAME}" \
        "${BUILD_DIR}/arm64/${APP_NAME}.app/Contents/MacOS/${APP_NAME}" \
        -output "${BUILD_DIR}/universal/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
    
    # Verify universal binary
    echo "Verifying universal binary..."
    lipo -info "${BUILD_DIR}/universal/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
    
    SOURCE_APP="${BUILD_DIR}/universal/${APP_NAME}.app"
else
    echo "Building for native architecture..."
    cmake -B "${BUILD_DIR}" -G Ninja \
        -DARCH=arm64 \
        -DCMAKE_BUILD_TYPE=Release \
        "${PROJECT_DIR}"
    cmake --build "${BUILD_DIR}"
    
    if [ ! -d "${BUILD_DIR}/${APP_NAME}.app" ]; then
        echo "Build failed: ${APP_NAME}.app not found"
        exit 1
    fi
    
    SOURCE_APP="${BUILD_DIR}/${APP_NAME}.app"
fi

# Create component package
echo "Creating component package..."
mkdir -p "${WORK_DIR}/app/Library/Input Methods"
cp -R "${SOURCE_APP}" "${WORK_DIR}/app/Library/Input Methods/"

pkgbuild \
    --root "${WORK_DIR}/app" \
    --component-plist "${PKG_DIR}/app.plist" \
    --identifier "${BUNDLE_ID}" \
    --version "${VERSION}" \
    --install-location / \
    --scripts "${PKG_DIR}/scripts" \
    "${WORK_DIR}/app.pkg"

# Create distribution package
echo "Creating distribution package..."
sed -e "s/%TITLE%/${APP_NAME} ${VERSION}/" \
    "${PKG_DIR}/distribution.xml.template" \
    > "${WORK_DIR}/distribution.xml"

productbuild \
    --distribution "${WORK_DIR}/distribution.xml" \
    --resources "${PKG_DIR}" \
    --package-path "${WORK_DIR}" \
    "${WORK_DIR}/${APP_NAME}-${VERSION}.pkg"

# Copy final PKG
cp "${WORK_DIR}/${APP_NAME}-${VERSION}.pkg" "${BUILD_DIR}/"

# Clean up work directory
rm -rf "${WORK_DIR}"

echo ""
echo "Package created: ${BUILD_DIR}/${APP_NAME}-${VERSION}.pkg"
