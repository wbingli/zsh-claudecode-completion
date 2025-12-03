---
description: Update zsh completions to match latest Claude CLI version
---

You are updating the zsh completion script for Claude Code CLI. Follow these steps:

## Step 1: Update Claude CLI

Run `claude update` to ensure we have the latest version.

## Step 2: Compare Versions

1. Get the installed Claude version:
!claude --version

2. Read the tracked version from the `claude-version` file in this repository.

3. Compare the versions. If they match, report "Completions are up to date" and stop.

## Step 3: Gather Help Output (if versions differ)

Run these commands to get the current CLI structure:
- `claude --help`
- `claude mcp --help`
- `claude plugin --help`
- `claude install --help`

## Step 4: Regenerate Completion Script

Read the existing `_claude` file and regenerate it based on the help output. Preserve the zsh completion structure:

- Use `#compdef claude` directive
- Define command arrays with descriptions
- Use `_arguments` for flags/options
- Use `_describe` for command listings
- Handle subcommands (mcp, plugin, install) with nested case statements
- Use early `return` after each case block to prevent fallthrough

Key patterns to follow:
- Flags with values: `'--flag[Description]:value:(option1 option2)'`
- Boolean flags: `'--flag[Description]'`
- Short+long flags: `'(-s --short)'{-s,--short}'[Description]'`
- Repeatable flags: `'*--flag[Description]:value:_files'`
- File completion: `:file:_files`
- Directory completion: `:directory:_files -/`

## Step 5: Update Version File

Write the new version number to the `claude-version` file.

## Step 6: Commit Changes

Stage and commit the changes:
```bash
git add claude-version _claude
git commit -m "Update completions for Claude vX.X.X"
```

Replace X.X.X with the actual new version number.
