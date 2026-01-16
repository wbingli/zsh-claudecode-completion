# Changelog

All notable changes to the zsh-claudecode-completion plugin are documented here.

## [2.1.9] - 2026-01-16

### Added
- New `--file` flag: File resources to download at startup with format `file_id:relative_path` (e.g., `--file file_abc:doc.txt file_def:img.png`)
- Added `plugin list` command with `--available` and `--json` flags for listing installed plugins
- Added `--json` flag to `plugin marketplace list` command for JSON output

## [2.1.7] - 2026-01-14

### Changed
- Updated all flag descriptions to provide more detailed information and context
- Updated `--agent` flag description: Now clarifies it "Overrides the agent setting"
- Updated `--allow-dangerously-skip-permissions` flag description: Added "without it being enabled by default" and recommendation note
- Updated `--allowedTools` and `--allowed-tools` flags: Added usage examples (e.g. "Bash(git:*) Edit")
- Updated `--betas` flag description: Added "(API key users only)" clarification
- Updated `--continue` flag description: Now specifies "in the current directory"
- Updated `--dangerously-skip-permissions` flag description: Added recommendation note for sandboxes
- Updated `--debug` flag description: Added detailed examples of category filtering (e.g., "api,hooks" or "!statsig,!file")
- Updated `--disallowedTools` and `--disallowed-tools` flags: Added usage examples (e.g. "Bash(git:*) Edit")
- Updated `--fallback-model` flag description: Added "when default model is overloaded (only works with --print)"
- Updated `--fork-session` flag description: Added "(use with --resume or --continue)" clarification
- Updated `--ide` flag description: Added "if exactly one valid IDE is available" condition
- Updated `--include-partial-messages` flag description: Added "(only works with --print and --output-format=stream-json)"
- Updated `--input-format` flag description: Added format details and constraints
- Updated `--max-budget-usd` flag description: Added "(only works with --print)" clarification
- Updated `--mcp-config` flag description: Added "(space-separated)" clarification
- Updated `--mcp-debug` flag description: Improved deprecation notice with migration guidance
- Updated `--model` flag description: Added more detailed explanation about aliases and full names
- Updated `--no-session-persistence` flag description: Added detailed explanation of behavior
- Updated `--output-format` flag description: Added detailed format descriptions
- Updated `--plugin-dir` flag description: Added "(repeatable)" clarification
- Updated `--print` flag description: Added important security note about workspace trust dialog
- Updated `--replay-user-messages` flag description: Added detailed constraints
- Updated `--resume` flag description: Added "or open interactive picker with optional search term"
- Updated `--session-id` flag description: Added "(must be a valid UUID)" requirement
- Updated `--setting-sources` flag description: Added explicit source options
- Updated `--settings` flag description: Added "to load additional settings from" clarification
- Updated `--strict-mcp-config` flag description: Added "ignoring all other MCP configurations"
- Updated `--tools` flag description: Added detailed usage instructions and examples
- Updated `mcp add` command flags: Improved descriptions with examples for `-e` and `-H` flags
- Updated `mcp add` command: Enhanced scope description format "(local, user, or project)"
- Updated `mcp add` command: Enhanced transport description with explicit types
- Updated `mcp remove` command: Enhanced scope description with clarification
- Updated `mcp add-json` command: Enhanced scope description format
- Updated `mcp add-from-claude-desktop` command: Enhanced scope description format
- Updated `plugin install` command: Enhanced scope description format with colon separator
- Updated `plugin uninstall` command: Enhanced scope description format with colon separator
- Updated `plugin enable` command: Enhanced scope description format
- Updated `plugin disable` command: Enhanced scope description format
- Updated `plugin update` command: Enhanced scope description format with comma separator
- Reordered flags in multiple commands to improve consistency (help flag first in many cases)

## [2.1.6] - 2026-01-13

### Changed
- Updated `--add-dir` flag to be repeatable (now accepts multiple directories)

## [2.1.5] - 2026-01-12

### Changed
- Updated `mcp add` command: Added "(default: local)" to scope flag description for clarity
- Updated `mcp add` command: Added "(defaults to stdio if not specified)" to transport flag description
- Updated `mcp remove` command: Enhanced scope flag description to clarify "(if not specified, removes from whichever scope it exists in)"
- Updated `mcp add-json` command: Added "(default: local)" to scope flag description
- Updated `mcp add-from-claude-desktop` command: Added "(default: local)" to scope flag description
- Updated `plugin install` command: Added "(default: user)" to scope flag description
- Updated `plugin uninstall` command: Added "(default: user)" to scope flag description
- Updated `plugin enable` command: Added "(default: user)" to scope flag description
- Updated `plugin disable` command: Added "(default: user)" to scope flag description
- Updated `plugin update` command: Added "(default: user)" to scope flag description
- Updated `plugin marketplace update` command: Made name parameter optional (now `::name:` instead of `:name:`) to support updating all marketplaces

## [2.1.4] - 2026-01-11

### Changed
- Updated description for `--disable-slash-commands` flag: Changed from "Disable all slash commands" to "Disable all skills"

## [2.1.1] - 2026-01-08

### Added
- Added `--help` flag completion for `mcp get` command
- Added `--help` flag completion for `mcp list` command
- Added `--help` flag completion for `mcp reset-project-choices` command
- Added `--help` flag completion for `plugin marketplace list` command
- Added `--help` flag completion for `setup-token`, `doctor`, and `update` commands

### Changed
- Updated completion script to match Claude CLI v2.1.1
- Alphabetically sorted commands and flags for better organization
- Improved argument completion for `mcp get` - now uses `_arguments` instead of `_message`
- Improved argument completion for `mcp list` - now uses `_arguments` instead of `_message`
- Improved argument completion for `mcp reset-project-choices` - now uses `_arguments` instead of `_message`
- Improved argument completion for `setup-token`, `doctor`, and `update` - now uses `_arguments` instead of `_message`

## [2.0.76] - 2026-01-06

No changes to completions. CLI structure remains the same as the previous version.

## [2.0.76] - 2026-01-04

### Changed
- Added version comment to completion script header for better tracking

## [2.0.75] - 2025-12-21

No changes to completions. CLI structure remains the same as 2.0.74.

## [2.0.74] - 2025-12-20

No changes to completions. CLI structure remains the same as 2.0.73.

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
