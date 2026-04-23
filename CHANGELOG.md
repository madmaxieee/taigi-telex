# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Multilingual installation guide attached to GitHub releases

### Changed
- Stable releases now read version from git tag instead of VERSION file
- Nightly builds marked as prerelease and no longer auto-promoted to latest release

## [0.1.1] - 2026-04-21

### Fixed
- Correct POJ tone position rules for vowel clusters
- Use breve (ă) for 9th tone in POJ mode instead of double acute (a̋), matching POJ convention

### Changed
- Reorder and simplify vowel priority tests

### Docs
- Simplify download and install instructions for non-technical users
- Add clear recommendation for "Latest Release" vs "Nightly builds"
- Split installation into two clear steps (Install Package, Add Input Method)

## [0.1.0] - 2026-04-20

### Added
- Initial release of Taigi Telex macOS input method
- Support for TL (Tâi-lô) and POJ (Pe̍h-ōe-jī) romanization
- Telex-style tone key input
- PKG installer for easy installation

[Unreleased]: https://github.com/madmax/taigi-telex/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/madmax/taigi-telex/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/madmax/taigi-telex/releases/tag/v0.1.0
