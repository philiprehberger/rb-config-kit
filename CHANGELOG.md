# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.1.4] - 2026-03-21

### Fixed
- Standardize Installation section in README

## [0.1.3] - 2026-03-18

### Changed
- Fix RuboCop Style/StringLiterals violations in gemspec

## [0.1.2] - 2026-03-16

### Fixed
- Fix CI: version test and rubocop compliance

## [0.1.1] - 2026-03-16

### Added
- Add License badge to README
- Add bug_tracker_uri to gemspec
- Add Development section to README
- Add Requirements section to README

## [0.1.0] - 2026-03-10

### Added

- Initial release
- Layered configuration resolution: defaults, YAML files, ENV variables
- Schema DSL with `string`, `integer`, `boolean`, and `float` types
- Immutable `Store` with `get`, `[]`, `to_h`, `keys`, and `key?` methods
- Convenience entry point via `Philiprehberger::ConfigKit.define`
- Zero runtime dependencies
