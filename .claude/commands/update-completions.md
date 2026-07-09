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

### Hidden Commands

Some Claude CLI commands are **hidden** — they work but are not listed in `claude --help`. These must be included in completions even though they won't appear in the help output. Always gather their help output separately:

| Command | Help command | Description |
|---------|-------------|-------------|
| `remote-control` | `claude remote-control --help` | Connect local environment to claude.ai/code |
| `daemon` | `claude daemon --help` | Manage the background-session supervisor (`run`, `status`, `logs`, `uninstall`, `stop`) |

For each hidden command:
1. Run its `--help` to get flags and description
2. Also check the official docs at `https://code.claude.com/docs/en/<command-name>.md` for any flags not shown in `--help` (e.g., `remote-control` has `--sandbox`, `--no-sandbox`, `--verbose` documented but not in `--help`)
3. Include the command in both the `commands` array and the `case` statement, same as visible commands
4. Include it in the `'1:command:(...)'` list at the bottom
5. Also add it to the `known_commands` array used by the subcommand-position scanner; otherwise a hidden parent like `daemon` won't be detected and its subcommands (e.g. `daemon stop`) will route to the wrong top-level case

**Maintaining this list**: When you discover new hidden commands (e.g., a command referenced in docs or changelogs but missing from `--help`), add them to this table so future updates preserve them.

### Do NOT remove a command just because it's missing from `claude --help`

The completion script intentionally lists commands that are not in `claude --help` (see the Hidden Commands table above). Before deleting any command from `_claude` because you can't find it in the help output, **verify it is actually gone** by invoking it:

```bash
claude <command> --help 2>&1
```

- If you get a real usage block → the command exists, keep it (and add it to the Hidden Commands table above if it's missing).
- Only an `unknown command` / `error: unknown command '<name>'` style error means it has truly been removed.

When in doubt, probe the CLI rather than dropping the entry. Treat every command currently in `_claude` as "verify before remove."

### Hidden Flags

Some flags are accepted by the CLI but not listed as their own row in `claude --help`. They are typically referenced indirectly — for example, inside another flag's description using bracket notation like `--system-prompt[-file]` (meaning both `--system-prompt` and `--system-prompt-file` are real flags). **Do not remove a flag just because it lacks its own line in `--help`.** Before removing any flag, verify it is no longer accepted by invoking it (e.g., `claude --system-prompt-file /tmp/does-not-exist 2>&1`); a "file not found" / argument-shaped error means the flag still exists, only a "Bad option" / "unknown option" error means it is truly gone.

| Flag | How to detect | Verify it still exists |
|------|---------------|------------------------|
| `--system-prompt-file <file>` | Mentioned as `--system-prompt[-file]` in the `--bare` flag description | `claude --system-prompt-file /tmp/nope 2>&1` → "System prompt file not found" |
| `--append-system-prompt-file <file>` | Mentioned as `--append-system-prompt[-file]` in the `--bare` flag description | `claude --append-system-prompt-file /tmp/nope 2>&1` → "Append system prompt file not found" |
| `--advisor <model>` | Listed in the `Advanced` section of `/en/cli-reference.md` but absent from `--help` | `claude --advisor 2>&1` → "argument missing"; `claude --advisor foo -p hi` → "cannot be used as an advisor" |
| `--channels <servers...>` | Documented on `/en/channels.md`; absent from `--help` | `claude --channels 2>&1` → "argument missing"; `claude --channels foo -p hi` → "entries must be tagged" |
| `--cloud` (alias `--remote`, deprecated) | Documented on `/en/claude-code-on-the-web.md`; absent from `--help` | `claude --cloud -p hi 2>&1` → "--cloud cannot be combined with --print" (same for `--remote`) |
| `--dangerously-load-development-channels <servers...>` | Documented on `/en/channels.md` (testing a channel during research preview); absent from `--help` | `claude --dangerously-load-development-channels 2>&1` → "argument missing" |
| `--init` / `--init-only` | Listed in the `Development & Debugging` section of `/en/cli-reference.md`; absent from `--help` | `claude --init-only 2>&1` exits 0 without an "unknown option" error |
| `--max-turns <turns>` | Listed in the `Print Mode` section of `/en/cli-reference.md`; absent from `--help` | `claude --max-turns 2>&1` → "argument missing" |
| `--permission-prompt-tool <tool>` | Listed in the `Advanced` section of `/en/cli-reference.md`; absent from `--help` | `claude --permission-prompt-tool 2>&1` → "argument missing" |
| `--teammate-mode <mode>` | Listed in the `Advanced` section of `/en/cli-reference.md`; absent from `--help` | `claude --teammate-mode 2>&1` → "argument missing"; invalid value lists choices `auto, tmux, iterm2, in-process` |
| `--teleport [session-id]` | Documented on `/en/claude-code-on-the-web.md` (`--teleport` pulls a cloud session into the terminal); absent from `--help` | `claude --teleport 2>&1` runs without an "unknown option" error |

Note: `--sdk-url <url>` is also accepted but was deliberately excluded from completions — probing it returns "This flag is reserved for Remote Control worker processes connecting to Anthropic's backend," i.e. it's internal, not user-facing.

**Maintaining this list**: When you find another flag in this category (referenced only inside another flag's description, mentioned in docs but absent from `--help`, etc.), add it to the table so future regenerations preserve it. When in doubt, keep the flag and probe the CLI rather than dropping it.

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

## Step 5: Update Changelog

Maintain a `CHANGELOG.md` file in the repository root that tracks all completion updates.

### Changelog Format

The changelog should use this structure:

```markdown
# Changelog

All notable changes to the zsh-claudecode-completion plugin are documented here.

## [2.0.57] - 2024-01-15

### Added
- New `foo` command with flags: `--bar`, `--baz`
- New `--new-flag` option for `mcp` command
- New subcommand `plugin marketplace search`

### Changed
- Updated description for `--verbose` flag
- Modified `install` command options

### Removed
- Deprecated `old-command` command
- Removed `--legacy` flag from `config` command
```

### How to Generate Changelog Entry

1. **Capture the old version** before updating (from `claude-version` file)
2. **Analyze the diff** between the old and new `_claude` file to identify:
   - **Added**: New commands, subcommands, or flags that didn't exist before
   - **Changed**: Modified descriptions, renamed options, or updated argument types
   - **Removed**: Commands, subcommands, or flags that were deleted
3. **Create or append to `CHANGELOG.md`**:
   - If the file doesn't exist, create it with the header
   - Add a new version section at the top (below the header)
   - Include today's date in YYYY-MM-DD format
   - List all changes under appropriate categories (Added/Changed/Removed)
   - Only include categories that have changes (skip empty sections)

### Example Diff Analysis

If the diff shows:
```diff
+ '--new-option[Enable new feature]'
- '--old-option[Deprecated feature]'
  '--existing[Updated description here]'
```

The changelog entry would be:
```markdown
## [2.0.57] - 2024-01-15

### Added
- New `--new-option` flag: Enable new feature

### Changed
- Updated description for `--existing` flag

### Removed
- Removed `--old-option` flag (deprecated feature)
```

### Important Notes

- Be specific about what changed—include the actual flag/command names
- For new commands with multiple flags, list them together
- Group related changes logically
- If no changes were detected in a category, omit that category entirely

## Step 6: Create Pull Request (CI only)

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
   - Stage and commit: `git add claude-version _claude CHANGELOG.md && git commit -m "Update completions for Claude v${VERSION}"`
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
