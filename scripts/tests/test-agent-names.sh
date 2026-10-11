#!/bin/bash
#
# Test for `_claude_agents` (issue #226): `--agent` completes the agents
# defined under the user's and the project's `.claude/agents/`.
#
# Builds a fake $HOME with a git project inside it, then checks:
#   - user and project agents, including files in subfolders
#   - project agents are found from a subdirectory of the project, and the
#     definition closest to the working directory wins
#   - the name comes from the frontmatter: comments, trailing whitespace,
#     quotes, CRLF line endings and a byte-order mark are handled
#   - `description: |` shows the text, not the `|`
#   - malformed files are skipped without hiding the valid ones
#   - CLAUDE_CONFIG_DIR replaces ~/.claude

set -e
TEST_NAME=test-agent-names
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

# Drop CSI escape sequences (colors, bold, bracketed paste) from tty output.
strip_ansi() {
    sed $'s/\033\\[[0-9;?]*[A-Za-z]//g' <<< "$1"
}

user_agents="$home/.claude/agents"
proj="$home/proj"
mkdir -p "$user_agents/review" "$proj/.git" "$proj/.claude/agents/team" \
         "$proj/sub/.claude/agents" "$proj/sub/deeper"

# --- user agents -----------------------------------------------------------
printf -- '---\nname: user-simple\ndescription: Plain user agent\n---\nbody\n' \
    > "$user_agents/user-simple.md"
# In a subfolder, and the file name differs from the agent name.
printf -- '---\nname: nested-reviewer\ndescription: Lives in a subfolder\n---\n' \
    > "$user_agents/review/some-file.md"
printf -- '---\nname: commented # not part of the name\ndescription: Has a comment # also dropped\n---\n' \
    > "$user_agents/commented.md"
printf -- '---\nname: tabbed\t\ndescription: Trailing tab\n---\n' \
    > "$user_agents/tabbed.md"
printf -- '---\nname: "quoted-name"\ndescription: '\''Single quoted text'\''\n---\n' \
    > "$user_agents/quoted.md"
printf -- '---\r\nname: crlf-agent\r\ndescription: Windows line endings\r\n---\r\n' \
    > "$user_agents/crlf.md"
printf -- '\xef\xbb\xbf---\nname: bom-agent\ndescription: Starts with a byte-order mark\n---\n' \
    > "$user_agents/bom.md"
printf -- '---\nname: block-agent\ndescription: |\n  First line of the block\n  second line\n---\n' \
    > "$user_agents/block.md"

# --- files that must be skipped --------------------------------------------
printf -- 'no frontmatter here\nname: no-frontmatter\n' > "$user_agents/plain.md"
printf -- '---\nname: scoped:name\ndescription: Colon is reserved\n---\n' > "$user_agents/colon.md"
printf -- '---\ndescription: Has no name\n---\n' > "$user_agents/nameless.md"
: > "$user_agents/empty.md"
printf -- '\x00\x01\x02\xff\xfe binary\n' > "$user_agents/binary.md"

# --- project agents --------------------------------------------------------
printf -- '---\nname: proj-agent\ndescription: Project level agent\n---\n' \
    > "$proj/.claude/agents/proj-agent.md"
printf -- '---\nname: team-agent\ndescription: Project agent in a subfolder\n---\n' \
    > "$proj/.claude/agents/team/member.md"
printf -- '---\nname: shared-name\ndescription: Farther definition\n---\n' \
    > "$proj/.claude/agents/shared.md"
printf -- '---\nname: shared-name\ndescription: Closest definition\n---\n' \
    > "$proj/sub/.claude/agents/shared.md"

log "case 1: user and project agents, from a project subdirectory"
output=$(run_completion "$home" "$proj/sub/deeper" 'claude --agent \t')
assert_no_completion_errors "$output"
for name in user-simple nested-reviewer commented quoted-name crlf-agent \
            bom-agent block-agent proj-agent team-agent shared-name; do
    assert_contains "$name" "$output" "agent list"
done

log "case 2: labels come out clean"
assert_not_contains "not part of the name" "$output" "agent list"
assert_not_contains "also dropped" "$output" "agent list"
assert_not_contains "some-file" "$output" "agent list"
assert_contains "First line of the block" "$output" "block description"
assert_not_contains "-- |" "$output" "block description"
assert_contains "Single quoted text" "$output" "quoted description"

log "case 3: the definition closest to the working directory wins"
assert_contains "Closest definition" "$output" "agent list"
assert_not_contains "Farther definition" "$output" "agent list"

log "case 4: malformed files are skipped"
for bad in no-frontmatter scoped nameless empty binary; do
    assert_not_contains "$bad" "$output" "agent list"
done

# A unique match is inserted followed by the space zsh will add (bold on
# terminals that can do it, hence strip_ansi). A name that kept its
# trailing tab or comment would not complete this way.
log "case 5: a name with trailing whitespace completes exactly"
output=$(run_completion "$home" "$proj" 'claude --agent tabb\t')
assert_no_completion_errors "$output"
assert_contains "agent tabbed " "$(strip_ansi "$output")" "completed name"
output=$(run_completion "$home" "$proj" 'claude --agent comm\t')
assert_no_completion_errors "$output"
assert_contains "agent commented " "$(strip_ansi "$output")" "completed name"

log "case 6: 'claude agents --agent <TAB>' uses the same list"
output=$(run_completion "$home" "$proj" 'claude agents --agent \t')
assert_no_completion_errors "$output"
assert_contains "proj-agent" "$output" "agents --agent list"
assert_contains "user-simple" "$output" "agents --agent list"

log "case 7: outside the project only user agents are offered"
output=$(run_completion "$home" "$home" 'claude --agent \t')
assert_no_completion_errors "$output"
assert_contains "user-simple" "$output" "agent list outside the project"
assert_not_contains "proj-agent" "$output" "agent list outside the project"

# Run these from a directory other than $home: with $home as the working
# directory, $home/.claude/agents is also the project's agents directory.
log "case 8: CLAUDE_CONFIG_DIR replaces ~/.claude"
mkdir -p "$home/altconfig/agents" "$home/elsewhere"
printf -- '---\nname: alt-agent\ndescription: From the alternate config dir\n---\n' \
    > "$home/altconfig/agents/alt.md"
output=$(run_completion "$home" "$home/elsewhere" 'claude --agent \t' \
    "set env(CLAUDE_CONFIG_DIR) \"$home/altconfig\"")
assert_no_completion_errors "$output"
assert_contains "alt-agent" "$output" "agent list with CLAUDE_CONFIG_DIR"
assert_not_contains "user-simple" "$output" "agent list with CLAUDE_CONFIG_DIR"

log "case 9: no agents directory at all is not an error"
mkdir -p "$home/empty-config"
output=$(run_completion "$home" "$home/elsewhere" 'claude --agent \t' \
    "set env(CLAUDE_CONFIG_DIR) \"$home/empty-config\"")
assert_no_completion_errors "$output"

pass "agent name completion OK"
