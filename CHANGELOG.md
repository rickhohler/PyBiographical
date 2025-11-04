# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial public release preparation
- Documentation cleanup for public repository

## [0.2.0] - 2025-11-04

### Added
- Person metadata management module (`pybiographical.persons`)
  - `PersonCRUD` class for create, read, update, delete operations
  - Person metadata models (`PersonFile`, `ValidationIssue`, `SearchResult`)
  - Person YAML validation with auto-fix capabilities
- Name registry with confidence scoring (`pybiographical.names`)
- Location data management (`pybiographical.locations`)
- Fuzzy matching utilities (`pybiographical.matching`)
  - Name matching with normalization
  - Location matching with abbreviation handling
  - Configurable confidence thresholds
- YAML I/O utilities (`pybiographical.io`)
  - Safe YAML loading and dumping with ruamel.yaml
  - Automatic backup creation with timestamps
  - Atomic file writes
  - File checksum computation (SHA-256, MD5)
- Environment variable management (`pybiographical.env`)
  - Centralized environment configuration
  - Type-safe environment variable access

### Changed
- Package renamed from `pycommon` to `pybiographical`
- License changed from Private to MIT for public release
- All genealogy-specific terminology replaced with generic biographical terms
- Documentation updated for public audience

## [0.1.0] - 2025-11-03

### Added
- RAM disk utilities for high-performance I/O on macOS
  - `RAMDiskContext` context manager
  - Automatic file staging and copy-back
  - 2-4x performance improvement for cloud-synced directories

[Unreleased]: https://github.com/username/PyBiographical/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/username/PyBiographical/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/username/PyBiographical/releases/tag/v0.1.0
