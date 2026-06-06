# Changelog

All notable changes to the zsh-claudecode-completion plugin are documented here.

## [2.1.167] - 2026-06-06

### Added
- New `--strict` flag for `plugin validate` subcommand: Treat warnings as errors (exit 1), useful in CI

### Changed
- Updated `--model` flag description example from `claude-sonnet-4-6` to `claude-opus-4-8`

## [2.1.160] - 2026-06-02

### Added
- New `--prompt-suggestions` flag at top level: Enable prompt suggestions (choices: true, false, 1, 0, yes, no, on, off)
- New `--agent` flag for `agents` subcommand: Default agent for sessions dispatched from agent view
- New `plugin init` / `plugin new` subcommand with flags: `--author`, `--author-email`, `--description`, `--force`, `--with`

## [2.1.153] - 2026-05-28

### Added
- New `--scope` flag for `plugin marketplace remove` subcommand: Remove the marketplace declaration from a specific settings scope (user, project, or local)

## [2.1.152] - 2026-05-27

### Changed
- Bumped tracked CLI version to 2.1.152; no flag or command surface changes.

## [2.1.150] - 2026-05-26

### Changed
- Bumped tracked CLI version to 2.1.150; no flag or command surface changes.

## [2.1.148] - 2026-05-22

### Added
- New `--config` flag for `plugin install` subcommand: Set a userConfig option declared in the plugin's manifest (repeatable)

### Changed
- Updated `-y/--yes` description for `plugin prune` and `plugin uninstall` to reflect that TTY check applies to both stdin and stdout

## [2.1.145] - 2026-05-20

### Added
- New `--json` flag for `agents` subcommand: Print live sessions as a JSON array and exit (for scripting; does not require a TTY)

## [2.1.144] - 2026-05-19

### Changed
- Bumped tracked CLI version to 2.1.144; no flag or command surface changes.

## Unreleased

### Changed
- `claude -r <TAB>` / `claude --resume <TAB>` now labels sessions the same way the in-CLI `/resume` picker does: relative time, branch, file size, short id, and the session title — e.g. `1 day ago · main · 2.5MB - 4bd38c17: refactor-auth-flow`. The completer now reads, in priority order: `/rename`-set `customTitle`, auto-generated `aiTitle`, `sessions-index.json` `summary`, inline JSONL summary, the first non-command user prompt, and finally the slash command name (e.g. `/exit`) so command-only sessions still appear instead of being silently dropped.

## [2.1.143] - 2026-05-16

### Added
- New `--add-dir` flag for `agents` subcommand: Additional directory to allow tool access to in dispatched sessions (repeatable)
- New `--allow-dangerously-skip-permissions` flag for `agents` subcommand: Make bypass-permissions mode available to dispatched sessions without defaulting to it
- New `--dangerously-skip-permissions` flag for `agents` subcommand: Alias for --permission-mode bypassPermissions
- New `--effort` flag for `agents` subcommand: Default effort level for sessions dispatched from agent view (low, medium, high, xhigh, max)
- New `--mcp-config` flag for `agents` subcommand: MCP server configuration to apply to dispatched sessions (repeatable)
- New `--model` flag for `agents` subcommand: Default model for sessions dispatched from agent view
- New `--permission-mode` flag for `agents` subcommand: Default permission mode for sessions dispatched from agent view
- New `--plugin-dir` flag for `agents` subcommand: Load plugins from specified directory for the agent view and dispatched sessions (repeatable)
- New `--settings` flag for `agents` subcommand: Settings file or JSON string to apply to the agent view and dispatched sessions
- New `--strict-mcp-config` flag for `agents` subcommand: Only use MCP servers from --mcp-config in dispatched sessions

## [2.1.141] - 2026-05-14

### Added
- New `--cwd <path>` flag for `agents` subcommand: Show only background sessions started under the given path

## [2.1.140] - 2026-05-13

### Changed
- Bumped tracked CLI version to 2.1.140; no flag or command surface changes.
- `/update-completions` now documents "hidden flags" (e.g. `--system-prompt-file`, `--append-system-prompt-file`) that the CLI accepts but doesn't list as their own row in `claude --help`, and requires probing the CLI before removing any flag. Prevents regressions like the regeneration that proposed dropping `--system-prompt-file` / `--append-system-prompt-file` even though both are still accepted.
- Added a static test asserting the file-form `system-prompt` flags stay in `_claude`.

## [2.1.139] - 2026-05-12

### Added
- New `plugin details` subcommand: Show a plugin's component inventory and projected token cost
- New top-level commands for managing background sessions (agent view): `attach`, `logs`, `stop`, `kill` (alias for `stop`), `respawn` (with `--all`), and `rm`
- Background session ID completion for `attach`, `logs`, `stop`, `kill`, `respawn`, and `rm`: enumerates sessions from `~/.claude/jobs/<id>/state.json` (the same source `claude agents` uses) and labels each id with the session's name and state — e.g. `708aab4d [done] Test /bg command for session view`. Sessions are listed newest-first by `state.json` mtime to match `claude agents`'s ordering. Honors `CLAUDE_CONFIG_DIR`.

### Changed
- Updated `agents` command description to "Open agent view (manage background sessions)"

## [2.1.138] - 2026-05-09

### Added
- New `--plugin-url` flag: Fetch a plugin .zip from a URL for this session only (repeatable)
- New `--remote-control [name]` flag: Start an interactive session with Remote Control enabled (optionally named)

### Changed
- Updated `auto-mode defaults` description to include "soft_deny, and hard_deny"
- Updated `--print` flag description to match current CLI wording

### Removed
- Removed `--client-secret` flag from `mcp add-from-claude-desktop` (no longer shown in CLI help)

## [2.1.128] - 2026-05-05

No structural CLI changes detected between v2.1.126 and v2.1.128; version bump only.

## [2.1.126] - 2026-05-01

### Added
- New `project` command: Manage Claude Code project state
- New `project purge` subcommand: Delete all Claude Code state for a project (transcripts, tasks, file history, config entry), with flags: `--all`, `--dry-run`, `--interactive`, `--yes`

## [2.1.121] - 2026-04-28

### Added
- New `ultrareview` command: Run a cloud-hosted multi-agent code review of the current branch (or a PR number / base branch) and print the findings, with flags: `--json`, `--timeout`
- New `plugin prune|autoremove` subcommand: Remove auto-installed dependencies that are no longer needed, with flags: `--dry-run`, `--scope`, `--yes`
- New `--prune` flag for `plugin uninstall`: Also remove auto-installed dependencies that are no longer needed
- New `--yes/-y` flag for `plugin uninstall`: Skip the `--prune` confirmation prompt

## [2.1.119] - 2026-04-24

### Added
- New `plugin tag` subcommand: Create a `{name}--v{version}` git tag for a plugin release, with flags: `--dry-run`, `--force`, `--message`, `--push`, `--remote`

### Changed
- Updated `agents` command description: "Manage background and configured agents" (was "List configured agents")

## [2.1.116] - 2026-04-21

### Added
- New `--system-prompt-file` flag: Read system prompt from a file (hidden flag referenced in `--bare` help text)
- New `--append-system-prompt-file` flag: Append a system prompt from a file to the default system prompt (hidden flag)
- Added `plugins` as an alias command for `plugin` (matches CLI's `plugin|plugins` display)

## [2.1.114] - 2026-04-19

### Added
- New `--client-secret` flag for `mcp add-from-claude-desktop`: Prompt for OAuth client secret (or set MCP_CLIENT_SECRET env var)

### Changed
- Updated `--name` flag description: now mentions the prompt box and /resume picker — "(shown in the prompt box, /resume picker, and terminal title)"

## [2.1.112] - 2026-04-17

### Changed
- Added `xhigh` effort level to `--effort` flag options: `(low medium high xhigh max)`

## [2.1.109] - 2026-04-15

No changes to completions. CLI structure remains the same as v2.1.107.

## [2.1.107] - 2026-04-14

No changes to completions. CLI structure remains the same as v2.1.104.

## [2.1.104] - 2026-04-12

No changes to completions. CLI structure remains the same as v2.1.101.

## [2.1.101] - 2026-04-11

### Added
- New `--exclude-dynamic-system-prompt-sections` flag: Move per-machine sections (cwd, env info, memory paths, git status) from the system prompt into the first user message. Improves cross-user prompt-cache reuse. Only applies with the default system prompt (ignored with --system-prompt).

## [2.1.92] - 2026-04-04

### Added
- New `--include-hook-events` flag: Include all hook lifecycle events in the output stream (only works with `--output-format=stream-json`)
- New `--remote-control-session-name-prefix` flag: Prefix for auto-generated Remote Control session names (default: hostname)

## [2.1.87] - 2026-03-29

No changes to completions. CLI structure remains the same as v2.1.83.

## [2.1.83] - 2026-03-25

No changes to completions. CLI structure remains the same as v2.1.81.

## [2.1.81] - 2026-03-24

### Added
- New `auto-mode` command with subcommands: `config`, `critique`, `defaults`
- New `--bare` flag: Minimal mode that skips hooks, LSP, plugin sync, and other non-essential features
- New `--keep-data` flag for `plugin uninstall`: Preserve the plugin's persistent data directory

## [2.1.80] - 2026-03-20

### Added
- New `--claudeai` flag for `auth login`: Use Claude subscription (default)
- New `--console` flag for `auth login`: Use Anthropic Console (API usage billing) instead of Claude subscription

## [2.1.76] - 2026-03-14

### Added
- New `-n, --name` flag: Set a display name for this session (shown in /resume and terminal title)

## [2.1.72] - 2026-03-10

### Added
- New `--brief` flag: Enable SendUserMessage tool for agent-to-user communication

### Changed
- Updated `--effort` flag to include `max` as a valid level option (now: low, medium, high, max)

## [2.1.71] - 2026-03-07

### Changed
- Added `auto` as a new choice for `--permission-mode` flag

## [2.1.68] - 2026-03-04

No changes to completions. CLI structure remains the same as v2.1.63.

## [2.1.63] - 2026-02-28

### Added
- New `--scope` flag for `plugin marketplace add` command: Where to declare the marketplace (user, project, or local)
- New `--sparse` flag for `plugin marketplace add` command: Limit checkout to specific directories via git sparse-checkout (for monorepos)

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
