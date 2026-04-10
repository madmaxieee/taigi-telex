// swift-tools-version:5.9
// This Package.swift supports Swift Testing and sourcekit-lsp.
// The actual build system is CMake - see README.md for build instructions.

import PackageDescription

let package = Package(
  name: "TaigiTelex",
  platforms: [
    .macOS(.v11)
  ],
  targets: [
    // Library target for testing (core logic only)
    .target(
      name: "TaigiTelexLib",
      path: "src/lib",
      swiftSettings: []
    ),
    // Test target
    .testTarget(
      name: "TaigiTelexTests",
      dependencies: ["TaigiTelexLib"],
      path: "test"
    ),
    // Executable target for LSP support (includes all files)
    .executableTarget(
      name: "TaigiTelex",
      dependencies: ["TaigiTelexLib"],
      path: "src",
      exclude: ["lib"],
      swiftSettings: []
    ),
  ]
)
