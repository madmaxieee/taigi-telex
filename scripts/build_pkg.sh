#!/bin/bash
set -euo pipefail

# TaigiTelex PKG Builder
# This script builds an unsigned PKG installer for TaigiTelex input method

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_DIR}/build"
PKG_DIR="${PROJECT_DIR}/pkg"
WORK_DIR="${BUILD_DIR}/pkg_work"
VERSION=$(cat "${PROJECT_DIR}/VERSION")

BUNDLE_ID="com.kahiok.inputmethod.TaigiTelex"
APP_NAME="TaigiTelex"
APP_PKG="${WORK_DIR}/app.pkg"
INSTALLER_PKG="${WORK_DIR}/${APP_NAME}-${VERSION}.pkg"
FINAL_PKG="${BUILD_DIR}/${APP_NAME}-${VERSION}.pkg"
FINAL_DMG="${BUILD_DIR}/${APP_NAME}-${VERSION}.dmg"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Clean up previous builds
cleanup() {
    log_info "Cleaning up work directory..."
    rm -rf "${WORK_DIR}"
    mkdir -p "${WORK_DIR}"
    mkdir -p "${WORK_DIR}/pkg"
}

# Build the app using CMake
build_app() {
    log_info "Building ${APP_NAME}..."
    
    # Ensure build directory exists
    mkdir -p "${BUILD_DIR}"
    
    # Configure and build with CMake
    cmake -B "${BUILD_DIR}" -G Ninja \
        -DARCH=arm64 \
        -DCMAKE_BUILD_TYPE=Release \
        "${PROJECT_DIR}"
    
    cmake --build "${BUILD_DIR}"
    
    if [ ! -d "${BUILD_DIR}/${APP_NAME}.app" ]; then
        log_error "Build failed: ${APP_NAME}.app not found"
        exit 1
    fi
    
    log_info "Build successful"
}

# Create the component package
create_component_pkg() {
    log_info "Creating component package..."
    
    # Create directory structure
    mkdir -p "${WORK_DIR}/app/Library/Input Methods"
    
    # Copy the built app
    cp -R "${BUILD_DIR}/${APP_NAME}.app" "${WORK_DIR}/app/Library/Input Methods/"
    
    # Build the component package
    pkgbuild \
        --root "${WORK_DIR}/app" \
        --component-plist "${PKG_DIR}/app.plist" \
        --identifier "${BUNDLE_ID}" \
        --version "${VERSION}" \
        --install-location / \
        --scripts "${PKG_DIR}/scripts" \
        "${APP_PKG}"
    
    log_info "Component package created: ${APP_PKG}"
}

# Create the distribution package
create_distribution_pkg() {
    log_info "Creating distribution package..."
    
    # Generate distribution.xml from template
    sed -e "s/%TITLE%/${APP_NAME} ${VERSION}/" \
        "${PKG_DIR}/distribution.xml.template" \
        > "${WORK_DIR}/distribution.xml"
    
    # Build the distribution package (unsigned)
    productbuild \
        --distribution "${WORK_DIR}/distribution.xml" \
        --resources "${PKG_DIR}" \
        --package-path "${WORK_DIR}" \
        "${INSTALLER_PKG}"
    
    log_info "Distribution package created: ${INSTALLER_PKG}"
}

# Copy final PKG to build directory
copy_final_pkg() {
    log_info "Copying final PKG to build directory..."
    cp "${INSTALLER_PKG}" "${FINAL_PKG}"
    log_info "Final PKG: ${FINAL_PKG}"
}

# Create DMG containing the PKG
create_dmg() {
    log_info "Creating DMG with PKG..."
    
    # Create a temporary directory for DMG contents
    DMG_STAGING="${WORK_DIR}/dmg_staging"
    mkdir -p "${DMG_STAGING}"
    
    # Copy the PKG and LICENSE
    cp "${FINAL_PKG}" "${DMG_STAGING}/"
    cp "${PKG_DIR}/LICENSE.txt" "${DMG_STAGING}/LICENSE.txt"
    
    # Remove existing DMG if it exists
    if [ -f "${FINAL_DMG}" ]; then
        rm "${FINAL_DMG}"
    fi
    
    # Create the DMG
    hdiutil create \
        -srcfolder "${DMG_STAGING}" \
        -volname "${APP_NAME}-${VERSION}" \
        -fs HFS+ \
        -format UDZO \
        "${FINAL_DMG}"
    
    log_info "DMG created: ${FINAL_DMG}"
}

# Show usage
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -b, --build-only    Build the app only, skip packaging"
    echo "  -p, --pkg-only      Package only, skip build (requires existing build)"
    echo "  -d, --dmg           Create DMG containing the PKG (default)"
    echo "  -n, --no-dmg        Create PKG only, skip DMG creation"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  Build and package (creates both PKG and DMG)"
    echo "  $0 --build-only     Build the app only"
    echo "  $0 --pkg-only       Package using existing build"
    echo "  $0 --no-dmg         Build and package, but skip DMG"
}

# Main execution
main() {
    local build_only=false
    local pkg_only=false
    local create_dmg_flag=true
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--build-only)
                build_only=true
                shift
                ;;
            -p|--pkg-only)
                pkg_only=true
                shift
                ;;
            -d|--dmg)
                create_dmg_flag=true
                shift
                ;;
            -n|--no-dmg)
                create_dmg_flag=false
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    log_info "TaigiTelex PKG Builder"
    log_info "Version: ${VERSION}"
    log_info "Bundle ID: ${BUNDLE_ID}"
    echo ""
    
    # Validate options
    if [ "$build_only" = true ] && [ "$pkg_only" = true ]; then
        log_error "Cannot use --build-only and --pkg-only together"
        exit 1
    fi
    
    # Build
    if [ "$pkg_only" = false ]; then
        cleanup
        build_app
    else
        # Validate that build exists
        if [ ! -d "${BUILD_DIR}/${APP_NAME}.app" ]; then
            log_error "No existing build found. Run without --pkg-only first."
            exit 1
        fi
        cleanup
    fi
    
    # Exit if build-only
    if [ "$build_only" = true ]; then
        log_info "Build complete. Skipping packaging."
        exit 0
    fi
    
    # Package
    create_component_pkg
    create_distribution_pkg
    copy_final_pkg
    
    # Create DMG if requested
    if [ "$create_dmg_flag" = true ]; then
        create_dmg
    fi
    
    echo ""
    log_info "Packaging complete!"
    log_info "PKG: ${FINAL_PKG}"
    if [ "$create_dmg_flag" = true ]; then
        log_info "DMG: ${FINAL_DMG}"
    fi
    
    # Cleanup work directory
    rm -rf "${WORK_DIR}"
}

main "$@"
