# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A minimal zsh completion plugin for the Claude Code CLI. Provides tab completion only—no aliases, wrapper functions, or opinionated workflows.

## Key Files

- **`_claude`** - Main completion script using zsh's `#compdef` system. Contains all completion logic for commands, subcommands, and flags.
- **`zsh-claudecode-completion.plugin.zsh`** - Oh My Zsh plugin entry point. Copies `_claude` to `$ZSH_CACHE_DIR/completions/` to avoid fpath duplication issues.
- **`claude-version`** - Tracks which Claude CLI version the completions are based on.
- **`.claude/commands/`** - Slash commands for Claude Code (e.g., `/update-completions`).

## Architecture

The completion system uses standard zsh completion functions:
- `_arguments` for flag/option handling
- `_describe` for listing commands with descriptions
- `_files` for path completion
- Context variables: `$words` (command line words), `CURRENT` (cursor position)

The `_claude` script uses a case statement with early returns to route between subcommands (mcp, plugin, install, etc.).

## Development Notes

No build system, tests, or linting—pure zsh scripts only.

To test changes:
1. Source the plugin: `source zsh-claudecode-completion.plugin.zsh`
2. Reload completions: `autoload -Uz compinit && compinit`
3. Test with: `claude <TAB>`

## Known Patterns

- Avoid nested helper functions in `_claude`—they caused duplicate completions (see commit ff451fe)
- Use flat structure with explicit `return` statements after each case block
- Plugin copies `_claude` to cache directory instead of adding to fpath—prevents duplicates when plugin dir is symlinked

## Git Notes

The `.claude/` folder may be in the global `.gitignore`. Always use `-f` flag when adding `.claude/` changes:
```bash
git add -f .claude/
```

## Slash Commands

### `/update-completions`
Updates the completion script to match the latest Claude CLI version. This command:
1. Runs `claude update` to upgrade the CLI
2. Compares installed version with `claude-version` file
3. If versions differ, regenerates `_claude` from `--help` outputs
4. Auto-commits the changes
