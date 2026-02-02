# Changelog

All notable changes to MacApp Fixer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-02

### 🎉 Initial Release

#### Features
- ✨ Drag & drop interface for fixing macOS security issues
- 🔓 Remove quarantine attribute from apps, DMGs, and PKGs
- ✍️ Ad-hoc code signing for .app files
- 🎨 Beautiful macOS native UI with glassmorphism
- 🔍 Smart file type detection (automatically applies correct operations)
- ⚙️ Configurable toggles for each operation
- 🪟 macOS 15+ support

#### Technical
- Built with Swift 6.0
- SwiftUI-based interface
- Swift Package Manager project structure
- Requires macOS 15.0 or later
- Ad-hoc signed binary

#### Security
- No network connections
- No data collection
- Open source and auditable
- Uses native macOS security tools (`xattr`, `codesign`)