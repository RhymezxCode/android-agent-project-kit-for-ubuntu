# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog.

## [0.2.0] - 2026-05-22

### Added

- Cross-platform installer options:
  - Linux/macOS: `--tools`, `--dry-run`, `--no-exclude`, `--backup-existing`
  - Windows: `-Tools`, `-DryRun`, `-NoExclude`, `-BackupExisting`
- Cross-platform doctor/audit scripts:
  - `doctor.sh`, `doctor-mac.sh`, `doctor-windows.ps1`
- Cross-platform uninstall scripts:
  - `uninstall-from-project.sh`, `uninstall-from-project-mac.sh`, `uninstall-from-project-windows.ps1`
- CI smoke tests across `ubuntu-latest`, `macos-latest`, and `windows-latest` via `.github/workflows/installer-smoke-tests.yml`.
- Public docs for Linux/macOS/Windows install, doctor, and uninstall flows.

### Changed

- `AGENTS.md` remains the single global source of truth.
- Installer workflow now supports selective tool surface installation.

## [0.1.0] - 2026-05-22

### Added

- Initial public Android agent project kit structure and baseline guidance files.
