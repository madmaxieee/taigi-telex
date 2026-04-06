#!/bin/bash
set -euo pipefail

# TaigiTelex PKG Builder
# Builds an unsigned PKG installer for TaigiTelex input method

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_DIR}/build"
PKG_DIR="${PROJECT_DIR}/pkg"
WORK_DIR="${BUILD_DIR}/pkg_work"
VERSION=$(cat "${PROJECT_DIR}/VERSION")

BUNDLE_ID="com.kahiok.inputmethod.TaigiTelex"
APP_NAME="TaigiTelex"

echo "Building TaigiTelex ${VERSION}..."

# Clean up work directory
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

# Build the app
echo "Building app..."
cmake -B "${BUILD_DIR}" -G Ninja \
    -DARCH=arm64 \
    -DCMAKE_BUILD_TYPE=Release \
    "${PROJECT_DIR}"
cmake --build "${BUILD_DIR}"

if [ ! -d "${BUILD_DIR}/${APP_NAME}.app" ]; then
    echo "Build failed: ${APP_NAME}.app not found"
    exit 1
fi

# Create component package
echo "Creating component package..."
mkdir -p "${WORK_DIR}/app/Library/Input Methods"
cp -R "${BUILD_DIR}/${APP_NAME}.app" "${WORK_DIR}/app/Library/Input Methods/"

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

# Clean up
rm -rf "${WORK_DIR}"

echo ""
echo "Package created: ${BUILD_DIR}/${APP_NAME}-${VERSION}.pkg"
