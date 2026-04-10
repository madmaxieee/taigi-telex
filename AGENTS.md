# Taigi Telex - Agent Guide

macOS input method for Taiwanese (Tâi-gí) with Telex-style tone keys. Supports TL (Tâi-lô) and POJ (Pe̍h-ōe-jī) romanization.

## Build System

**Primary build**: CMake + Ninja. Swift Package Manager is only for sourcekit-lsp and testing support.

See `mise.toml` for available tasks (build, install, reload, test, format, package).

## Architecture

| Directory    | Purpose                                                     |
| ------------ | ----------------------------------------------------------- |
| `src/lib/`   | Core logic library (TelexTypes, TelexRules, TelexEngine)    |
| `src/`       | macOS IMK input controller (server.swift, controller.swift) |
| `test/`      | Swift Testing framework test suites (not XCTest)            |
| `resources/` | Icons and localization files                                |
| `pkg/`       | PKG installer templates and scripts                         |

## Development Workflow

1. After code changes: `mise run format`
2. Test: `mise run test` (runs all tests in `test/` directory)
3. Build: `mise run build` (builds the input method)
