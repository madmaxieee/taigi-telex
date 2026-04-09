// swift-tools-version:5.9
// This Package.swift is for sourcekit-lsp support only.
// The actual build system is CMake - see README.md for build instructions.

import PackageDescription

let package = Package(
    name: "TaigiTelex",
    platforms: [
        .macOS(.v11)
    ],
    targets: [
        .executableTarget(
            name: "TaigiTelex",
            path: "src",
            swiftSettings: [
                .unsafeFlags([
                    "-F", "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks"
                ])
            ]
        )
    ]
)
