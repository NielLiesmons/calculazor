# Changelog

All notable changes to **Calculazor** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-03-20

### Added

- Numeric keypad for Right Triangle parameter inputs (decimal-friendly).
- `CHANGELOG.md` for release history.

### Changed

- Android adaptive launcher icon: dedicated foreground asset with `#222222` background for consistent appearance on the home screen.
- Geometry: Right Triangle list row uses no border; parameter rows in the solver modal use 16px corner radius to match input modals.
- Zapstore listing copy: short one-line description aligned with store presentation.

### Fixed

- **Powers and roots:** `x²`, `x³`, `x^y`, and `√` now parse correctly (Unicode superscripts and square-root symbol normalized for the math engine).
- **Error state:** “Error” uses a clear red gradient; a single backspace or any new input clears it immediately (no per-character delete).

### Build

- Enable Material Design fonts in `pubspec.yaml` (`uses-material-design: true`) so dependencies that use Material icons resolve cleanly at build time.

[1.0.2]: https://github.com/NielLiesmons/calculazor/compare/v1.0.1...v1.0.2
