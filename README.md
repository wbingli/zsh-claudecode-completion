# zsh-claudecode-completion

Minimal and always up-to-date zsh completions for [Claude Code CLI](https://github.com/anthropics/claude-code) 

- **Pure tab completion only** — no aliases, no wrapper functions, no opinionated workflows.
- **Always up-to-date within 24 hours** - scheduled github action run daily, Claude Code automatically regenerates completions when the CLI changes. No manual maintenance required.

## How It Works

1. **Claude Code** writes completion scripts for Claude Code
2. **Claude Code** writes slash commands to update Claude Code completions
3. **Claude Code** creates GitHub workflows to run the slash commands every morning
4. **Claude Code** opens PRs when updates are needed
5. **Me:** *sips coffee* → *clicks merge* → *resumes sipping*

🐢 It's Claude Code all the way down.

## Features

- Command completion for all subcommands (`mcp`, `plugin`, `install`, `update`, etc.)
- Option/flag completion with descriptions
- Value completion for:
  - Model names (`sonnet`, `opus`, `haiku`, full model IDs)
  - Output formats (`text`, `json`, `stream-json`)
  - Permission modes (`default`, `acceptEdits`, `bypassPermissions`, etc.)
  - Tool names (`Bash`, `Read`, `Write`, `Edit`, etc.)
- Context-aware: different completions based on current subcommand
- File/directory completion where appropriate

## Installation

### Oh My Zsh

```bash
git clone https://github.com/wbingli/zsh-claudecode-completion.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-claudecode-completion
```

Then add `zsh-claudecode-completion` to your plugins array in `~/.zshrc`:

```bash
plugins=(... zsh-claudecode-completion)
```

Reload your shell:

```bash
exec zsh
```

### Manual Installation

Clone the repository:

```bash
git clone https://github.com/wbingli/zsh-claudecode-completion.git
```

Add the directory to your `fpath` in `~/.zshrc`:

```bash
fpath=(/path/to/zsh-claudecode-completion $fpath)
autoload -Uz compinit && compinit
```

## Usage

Type `claude` followed by `Tab` to see available completions:

```bash
claude <TAB>              # Show commands and options
claude mcp <TAB>          # Show MCP subcommands
claude --model <TAB>      # Show model names
claude --output-format <TAB>  # Show output formats
claude --resume <TAB>     # Show recent sessions (newest first)
```

## Configuration

### `--resume` session cap

`claude --resume <TAB>` shows the **20 most recent sessions by default**, newest first. In projects with a long history (hundreds of session files) this avoids zsh's *"do you wish to see all N possibilities?"* pager and keeps completion near-instant.

Override via the `CLAUDE_COMPLETION_SESSION_LIMIT` environment variable in `~/.zshrc`:

```bash
export CLAUDE_COMPLETION_SESSION_LIMIT=50   # show top 50 instead of 20
export CLAUDE_COMPLETION_SESSION_LIMIT=0    # no cap — show every session
```

`0` (or any non-positive value) disables the cap entirely.

## Developer Guide

### Updating Completions

When a new Claude CLI version is released, update the completion script by running:

```bash
claude /update-completions
```

This command will:
1. Upgrade Claude CLI to the latest version
2. Check if the completion script is outdated
3. Regenerate `_claude` from the new `--help` output
4. Commit the changes automatically

## Troubleshooting

If completions don't work after installation, try:

```bash
rm -f ~/.zcompdump*
exec zsh
```

## License

MIT
