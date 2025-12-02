# zsh-claudecode-completion

Minimal zsh completion plugin for [Claude Code CLI](https://github.com/anthropics/claude-code).

**Pure tab completion only** - no aliases, no wrapper functions, no opinionated workflows.

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
git clone https://github.com/anthropics/zsh-claudecode-completion.git \
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
git clone https://github.com/anthropics/zsh-claudecode-completion.git
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
```

## Troubleshooting

If completions don't work after installation, try:

```bash
rm -f ~/.zcompdump*
exec zsh
```

## License

MIT
