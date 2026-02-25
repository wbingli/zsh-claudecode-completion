# Changelog

All notable changes to the zsh-claudecode-completion plugin are documented here.

## [2.1.55] - 2026-02-25

No changes to completions. CLI structure remains the same as v2.1.50.

## [2.1.50] - 2026-02-22

### Added
- New `agents` command: List configured agents (with `--setting-sources` option)
- New `upgrade` command alias for `update`: Check for updates and install if available

## [2.1.49] - 2026-02-20

### Added
- New `--tmux` flag: Create a tmux session for the worktree (requires --worktree). Uses iTerm2 native panes when available; use --tmux=classic for traditional tmux
- New `-w/--worktree` flag: Create a new git worktree for this session (optionally specify a name)

### Changed
- Updated `--model` flag description to reference `claude-sonnet-4-6` as the current model name example
- Updated `plugin enable` scope description: default is now `auto-detect` instead of `user`
- Updated `plugin disable` scope description: default is now `auto-detect` instead of `user`

### Removed
- Removed `delegate` from `--permission-mode` options (no longer listed in CLI help)

## [2.1.44] - 2026-02-17

No changes to completions. CLI structure remains the same as v2.1.42.

## [2.1.42] - 2026-02-14

No changes to completions. CLI structure remains the same as v2.1.41.

## [2.1.41] - 2026-02-13

### Added
- New `auth` command: Manage authentication
- New `auth login` subcommand: Sign in to your Anthropic account
  - Added `--email` flag: Pre-populate email address on the login page
  - Added `--sso` flag: Force SSO login flow
- New `auth logout` subcommand: Log out from your Anthropic account
- New `auth status` subcommand: Show authentication status
  - Added `--json` flag: Output as JSON (default)
  - Added `--text` flag: Output as human-readable text

## [2.1.39] - 2026-02-11

### Added
- New `--effort` flag: Effort level for the current session (low, medium, high)

## [2.1.37] - 2026-02-09

### Added
- New `--client-secret` flag for `mcp add-json` command: Prompt for OAuth client secret (or set MCP_CLIENT_SECRET env var)

## [2.1.34] - 2026-02-06

No changes to completions. CLI structure remains the same as v2.1.31.

## [2.1.31] - 2026-02-04

### Added
- New `--callback-port` flag for `mcp add` command: Fixed port for OAuth callback (for servers requiring pre-registered redirect URIs)
- New `--client-id` flag for `mcp add` command: OAuth client ID for HTTP/SSE servers
- New `--client-secret` flag for `mcp add` command: Prompt for OAuth client secret (or set MCP_CLIENT_SECRET env var)

### Changed
- Updated `--debug` flag description: Changed example from "!statsig,!file" to "!1p,!file" in category filtering examples

## [2.1.29] - 2026-02-01

No changes to completions. CLI structure remains the same as v2.1.27.

## [2.1.27] - 2026-01-31

### Added
- New `--from-pr` flag: Resume a session linked to a PR by PR number/URL, or open interactive picker with optional search term
- Added `--all` flag to `plugin disable` command: Disable all enabled plugins

### Changed
- Updated `plugin disable` command: Made plugin parameter optional to support disabling all plugins with `--all` flag

## [2.1.25] - 2026-01-30

No changes to completions. CLI structure remains the same as v2.1.22.

## [2.1.22] - 2026-01-28

No changes to completions. CLI structure remains the same as v2.1.20.

## [2.1.20] - 2026-01-27

### Added
- New `--debug-file` flag: Write debug logs to a specific file path (implicitly enables debug mode)

## [2.1.19] - 2026-01-24

### Changed
- Updated `mcp reset-project-choices` command description: Added more detailed explanation - "Reset all approved and rejected project-scoped (.mcp.json) servers within this project"

## [2.1.17] - 2026-01-23

### Changed
- Updated `install` command description: Added detailed usage information - "Use [target] to specify version (stable, latest, or specific version)"
- Updated `plugin install` and `plugin i` command descriptions: Added "(use plugin@marketplace for specific marketplace)" clarification
- Updated `plugin update` command description: Added "(restart required to apply)" notice
- Updated `plugin marketplace update` command description: Added "updates all if no name specified" clarification
- Updated `--file` flag description: Added example usage - "(e.g., --file file_abc:doc.txt file_def:img.png)"
- Updated `--json-schema` flag description: Added example schema - `{"type":"object","properties":{"name":{"type":"string"}},"required":["name"]}`
- Updated `--mcp-debug` flag description: Improved deprecation notice format - "[DEPRECATED. Use --debug instead]"
- Updated `--model` flag description: Added examples for aliases and full names - "(e.g. sonnet or opus)" and "(e.g. claude-sonnet-4-5-20250929)"
- Updated `--tools` flag description: Added example tool names - "(e.g. \"Bash,Edit,Read\")"
- Updated `mcp add` command `-H/--header` flag description: Added example with multiple headers - "(e.g. -H \"X-Api-Key: abc123\" -H \"X-Custom: value\")"

## [2.1.14] - 2026-01-21

No changes to completions. CLI structure remains the same as v2.1.12.

## [2.1.12] - 2026-01-18

### Added
- New `--file` flag: File resources to download at startup (Format: file_id:relative_path)
- Added `list` subcommand to `plugin` command: List installed plugins
- Added `--available` flag to `plugin list` command: Include available plugins from marketplaces (requires --json)
- Added `--json` flag to `plugin list` command: Output as JSON
- Added `--json` flag to `plugin marketplace list` command: Output as JSON

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
