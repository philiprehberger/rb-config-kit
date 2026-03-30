# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-03-29

### Added
- Nested configuration with dot-notation keys (e.g., `database.host`) mapped to nested YAML and uppercase ENV variables
- Array type declaration with `array(key, of: :type)` — splits ENV values by comma, coerces each element
- Hash type declaration with `hash_type(key)` — collects ENV vars matching `KEY_*` pattern into a hash
- Required key validation with `required(key, type:)` — raises `ConfigKit::MissingKeyError` at define-time if no value found
- Auto-generated ENV key mapping from key names (uppercased, dots replaced with underscores)

## [0.1.8] - 2026-03-26

### Changed
- Add Sponsor badge to README
- Fix License section format

## [0.1.7] - 2026-03-23

### Fixed
- Standardize README/CHANGELOG to match template guide

## [0.1.6] - 2026-03-22

### Added
- Expand test coverage to 30+ examples with edge cases for layer precedence, boolean casting, YAML edge cases, mixed types, frozen store, undefined keys

## [0.1.5] - 2026-03-22

### Changed
- Update rubocop configuration for Windows compatibility

## [0.1.4] - 2026-03-20

### Fixed
- Standardize Installation section in README
- Fix README description trailing period
- Fix CHANGELOG header wording

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
