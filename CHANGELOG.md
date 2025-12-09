# Changelog

All notable changes to the zsh-claudecode-completion plugin are documented here.

## [2.0.62] - 2025-12-09

### Added
- Added `--scope` flag to `plugin install` command with options: user, project, local
- Added `--scope` flag to `plugin uninstall` command with options: user, project, local
- Added `--help` flag completion for `plugin install` command
- Added `--help` flag completion for `plugin uninstall` command

### Changed
- Improved argument completion for `plugin install` - now uses `_arguments` instead of `_message`
- Improved argument completion for `plugin uninstall` - now uses `_arguments` instead of `_message`

## [2.0.61] - 2025-12-07

No changes to completions. CLI structure remains the same as 2.0.60.

## [2.0.60] - 2025-12-06

### Added
- New `--disable-slash-commands` flag: Disable all slash commands
