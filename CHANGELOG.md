# Changelog

All notable changes to the zsh-claudecode-completion plugin are documented here.

## [2.0.73] - 2025-12-19

No changes to completions. CLI structure remains the same as 2.0.72.

## [2.0.72] - 2025-12-18

No changes to completions. CLI structure remains the same as 2.0.71.

## [2.0.71] - 2025-12-17

### Added
- New `--chrome` flag: Enable Claude in Chrome integration
- New `--no-chrome` flag: Disable Claude in Chrome integration

## [2.0.70] - 2025-12-16

### Added
- Added `delegate` option to `--permission-mode` flag

## [2.0.69] - 2025-12-13

### Added
- Added `i` alias for `plugin install` subcommand
- Added `remove` alias for `plugin uninstall` subcommand
- Added `rm` alias for `plugin marketplace remove` subcommand

## [2.0.67] - 2025-12-12

No changes to completions. CLI structure remains the same as 2.0.65.

## [2.0.65] - 2025-12-11

### Added
- New `--max-budget-usd` flag: Maximum dollar amount to spend on API calls (only works with --print)
- New `update` subcommand for `plugin` command: Update a plugin to the latest version
- Added `--scope` flag to `plugin enable` command with options: user, project, local
- Added `--scope` flag to `plugin disable` command with options: user, project, local
- Added `--help` flag completion for `plugin enable` command
- Added `--help` flag completion for `plugin disable` command
- Added `--help` flag completion for `plugin marketplace add` command
- Added `--help` flag completion for `plugin marketplace remove` command
- Added `--help` flag completion for `plugin marketplace update` command

### Changed
- Improved argument completion for `plugin enable` - now uses `_arguments` instead of `_message`
- Improved argument completion for `plugin disable` - now uses `_arguments` instead of `_message`
- Improved argument completion for `plugin marketplace remove` - now uses `_arguments` instead of `_message`
- Improved argument completion for `plugin marketplace update` - now uses `_arguments` instead of `_message`
- Updated `plugin update` subcommand to include `managed` scope option in addition to user, project, local

## [2.0.64] - 2025-12-10

### Added
- New `--no-session-persistence` flag: Disable session persistence

### Changed
- Updated description for `--debug` flag: Now mentions "optional category filtering"
- Updated description for `--print` flag: Now includes "(useful for pipes)"
- Updated description for `--json-schema` flag: Added "validation" to description
- Updated description for `--allow-dangerously-skip-permissions` flag: Clarified "all permission checks"
- Updated description for `--replay-user-messages` flag: Changed "to stdout" to "back on stdout"
- Updated description for `--allowedTools` and `--allowed-tools` flags: Now includes "Comma or space-separated list"
- Updated description for `--tools` flag: Now includes "from the built-in set"
- Updated description for `--disallowedTools` and `--disallowed-tools` flags: Now includes "Comma or space-separated list"
- Updated description for `--system-prompt` flag: Added "to use" for clarity
- Updated description for `--append-system-prompt` flag: Added "a" for clarity
- Updated description for `--permission-mode` flag: Added "to use" for clarity
- Updated description for `--resume` flag: Changed parameter name from "sessionId" to "value"
- Updated description for `--fork-session` flag: Expanded description for clarity
- Updated description for `--model` flag: Changed "for the session" to "for the current session"
- Updated description for `--fallback-model` flag: Now mentions "Enable automatic fallback"
- Updated description for `--settings` flag: Added "a" before "settings JSON file"
- Updated description for `--add-dir` flag: Added "to" at the end
- Updated description for `--ide` flag: Now includes "Automatically"
- Updated description for `--session-id` flag: Expanded with "for the conversation"
- Updated description for `--setting-sources` flag: Added "to load" at the end
- Updated description for `--plugin-dir` flag: Added "for this session only"
- Updated description for `mcp add` command: Now includes "to Claude Code"
- Updated description for `mcp add-json` command: Clarified "(stdio or SSE) with a JSON string"
- Updated description for `mcp add-from-claude-desktop` command: Added platform note "(Mac and WSL only)"
- Updated description for `mcp reset-project-choices` command: Expanded to "Reset all approved and rejected project-scoped servers"
- Updated description for `plugin validate` command: Changed to "Validate a plugin or marketplace manifest"
- Updated description for `plugin marketplace` command: Changed to "Manage Claude Code marketplaces"
- Updated description for `plugin install` command: Expanded to "Install a plugin from available marketplaces"
- Updated description for `plugin uninstall` command: Changed to "Uninstall an installed plugin"
- Updated description for `plugin marketplace add` command: Added "a" before "URL"

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
