---
description: Update zsh completions to match latest Claude CLI version
allowed-arguments:
  - --force
  - --create-pr
---

You are updating the zsh completion script for Claude Code CLI. Follow these steps:

## Step 1: Check for Force Flag and Compare Versions

1. Check if `--force` was passed as an argument to this command (check $ARGUMENTS).

2. If `--force` is NOT present:
   - Get the installed Claude version: `claude --version`
   - Read the tracked version from the `claude-version` file in this repository
   - Compare the versions. If they match or the installed Claude version is lower than the tracked version, report "Completions are up to date" and stop.

3. If `--force` IS present:
   - Skip version comparison
   - Report "Force flag detected, regenerating completions regardless of version"
   - Continue to Step 2

## Step 2: Gather Help Output (if versions differ)

Run these commands to get the current CLI structure:
- `claude --help`
- `claude mcp --help`
- `claude plugin --help`
- `claude install --help`

### Important: How to gather a comphrehensive help output

Above are just examples, but you should gather help output for all top-level commands and subcommands as needed to fully capture the CLI structure for completions. Store this output for use in the next step.

It may have multiple sub commands. For example, `claude plugin` will have its own set of subcommands. In the meanwhile, `claude plugin marketplace` may also have its own set of subcommands. Make sure to capture all levels of subcommands as needed.

You need to iterate through every subcommand to get their help output as well. For example, start with `claude --help`. You will have all the top level commands and options. For each top level command, you will need to run `claude <top-level-command> --help` to get its subcommands and options. If any of those subcommands have their own subcommands, you will need to run `claude <top-level-command> <subcommand> --help` as well, and so on, until you have captured the full hierarchy of commands and options.

## Step 3: Regenerate Completion Script

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

## Step 4: Update Version File

Write the new version number to the `claude-version` file.

## Step 5: Create Pull Request (CI only)

**Only execute this step if `--create-pr` was passed as an argument.**

If `--create-pr` is NOT present, skip this step entirely and report that the files have been updated.

If `--create-pr` IS present, create a pull request:

1. **Get version info:**
   - Read the new version from `claude-version`
   - Generate a random 6-character suffix for branch uniqueness

2. **Configure git and create branch:**
   ```bash
   git config user.name "github-actions[bot]"
   git config user.email "github-actions[bot]@users.noreply.github.com"
   git checkout -b "auto-update/claude-completions-v${VERSION}-${SUFFIX}"
   ```

3. **Review changes and commit:**
   - Run `git diff` to see what changed in `_claude`
   - Analyze the diff to identify: new commands, removed commands, new flags, removed flags, description changes
   - Stage and commit: `git add claude-version _claude && git commit -m "Update completions for Claude v${VERSION}"`
   - Push: `git push -u origin "auto-update/claude-completions-v${VERSION}-${SUFFIX}"`

4. **Create PR with detailed description:**
   Use `gh pr create` with a body that includes:
   - **Summary**: Brief description of the update
   - **Changes**: Bullet list of specific changes (new commands, new flags, removed items, etc.)
   - **Version**: Old version → New version

   Example:
   ```bash
   gh pr create \
     --title "Update completions for Claude v${VERSION}" \
     --body "## Summary
   Automated update of zsh completions to match Claude CLI v${VERSION}.

   ## Changes
   - Added \`foo\` command with flags: --bar, --baz
   - Added --new-flag to \`mcp\` command
   - Removed deprecated \`old-command\`

   ## Version
   v${OLD_VERSION} → v${NEW_VERSION}" \
     --base main
   ```

   **Important**: The changes section should be based on your analysis of the actual diff, not placeholder text.

## IMPORTANT: Duplicate Completions Warning

After regenerating completions, you MUST verify the script doesn't cause duplicate entries.

### How the Plugin Avoids Duplicates
The plugin copies `_claude` to `$ZSH_CACHE_DIR/completions/` instead of adding to fpath directly.
This prevents duplicates when the plugin directory is symlinked (e.g., from oh-my-zsh custom/plugins).

### Verification Steps
1. Open a new terminal (or `source ~/.zshrc`)
2. Test: `claude --<TAB>`
   - EXPECTED: ~35-40 options listed normally
   - PROBLEM: "do you wish to see all X possibilities" where X > 100 indicates duplicate completions

3. If duplicates occur, clear the cache:
   ```bash
   rm -f ~/.zcompdump*
   rm -f ~/.oh-my-zsh/cache/completions/_claude
   source ~/.zshrc
   ```

### Known Anti-Patterns (AVOID)
These patterns cause duplicate completions and must NOT be used:
- Nested helper functions (e.g., `_claude_mcp()` called from main completion)
- `_arguments -C` with complex state machines (use `-s` instead)
- Missing `return` statement after case blocks
- `_claude() { }` wrapper function with `_claude "$@"` at end
- Adding plugin directory directly to fpath when it may be symlinked

### Required Structure
The completion script must use this flat structure:
- `case $words[2] in` for subcommand detection (not `$words[1]` which is always "claude")
- Early `return` after each case block to prevent fallthrough
- Simple `_arguments -s` (not `-C`) for main flags
- Simple command list: `'1:command:(cmd1 cmd2 cmd3)'`
