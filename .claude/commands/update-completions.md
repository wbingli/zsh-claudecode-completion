---
description: Update zsh completions to match latest Claude CLI version
allowed-arguments:
  - --force
---

You are updating the zsh completion script for Claude Code CLI. Follow these steps:

## Step 1: Update Claude CLI

Run `claude update` to ensure we have the latest version.

## Step 2: Check for Force Flag and Compare Versions

1. Check if `--force` was passed as an argument to this command (check $ARGUMENTS).

2. If `--force` is NOT present:
   - Get the installed Claude version: `claude --version`
   - Read the tracked version from the `claude-version` file in this repository
   - Compare the versions. If they match or the installed Claude version is lower than the tracked version, report "Completions are up to date" and stop.

3. If `--force` IS present:
   - Skip version comparison
   - Report "Force flag detected, regenerating completions regardless of version"
   - Continue to Step 3

## Step 3: Gather Help Output (if versions differ)

Run these commands to get the current CLI structure:
- `claude --help`
- `claude mcp --help`
- `claude plugin --help`
- `claude install --help`

### Important: How to gather a comphrehensive help output

Above are just examples, but you should gather help output for all top-level commands and subcommands as needed to fully capture the CLI structure for completions. Store this output for use in the next step.

It may have multiple sub commands. For example, `claude plugin` will have its own set of subcommands. In the meanwhile, `claude plugin marketplace` may also have its own set of subcommands. Make sure to capture all levels of subcommands as needed.

You need to iterate through every subcommand to get their help output as well. For example, start with `claude --help`. You will have all the top level commands and options. For each top level command, you will need to run `claude <top-level-command> --help` to get its subcommands and options. If any of those subcommands have their own subcommands, you will need to run `claude <top-level-command> <subcommand> --help` as well, and so on, until you have captured the full hierarchy of commands and options.

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

If `--force` was used and the version hasn't changed, use this commit message instead:
```bash
git commit -m "Regenerate completions for Claude vX.X.X (forced)"
```
