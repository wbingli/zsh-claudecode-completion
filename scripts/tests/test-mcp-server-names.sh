#!/bin/bash
#
# Test for `_claude_mcp_servers` (issue #227): `claude mcp get`, `remove`,
# `login` and `logout` complete the configured MCP server names.
#
# Builds a fake $HOME with a git project inside it, then checks:
#   - user, local and project scope are all read
#   - the project is found from a subdirectory and through a symlink
#   - a server of another project is not offered
#   - a malformed entry or file does not hide the valid servers, and
#     nothing prints a zsh error
#   - CLAUDE_CONFIG_DIR moves .claude.json

set -e
TEST_NAME=test-mcp-server-names
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps
require_dep jq

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

proj="$home/proj"
mkdir -p "$proj/.git" "$proj/sub/deeper" "$home/elsewhere" "$home/other"
ln -s "$proj" "$home/link"

write_user_config() {
    cat > "$1" <<JSON
{
  "mcpServers": {
    "user-srv": { "type": "stdio", "command": "npx" },
    "url-srv": { "type": "http", "url": "https://example.com/mcp?token=SECRETVALUE" },
    "scoped:srv": { "command": "node" },
    "broken-entry": ["not", "an", "object"]
  },
  "projects": {
    "$proj": { "mcpServers": { "local-srv": { "command": "python" } } },
    "$home/other": { "mcpServers": { "other-project-srv": { "command": "x" } } },
    "$home/elsewhere": "not an object"
  }
}
JSON
}
write_user_config "$home/.claude.json"

cat > "$proj/.mcp.json" <<'JSON'
{ "mcpServers": { "project-srv": { "type": "sse", "url": "https://example.org/sse" } } }
JSON

log "case 1: all three scopes, from a project subdirectory"
output=$(run_completion "$home" "$proj/sub/deeper" 'claude mcp get \t')
assert_no_completion_errors "$output"
for name in user-srv url-srv local-srv project-srv scoped:srv; do
    assert_contains "$name" "$output" "mcp get list"
done

log "case 2: other projects, bad entries and URL query strings are left out"
assert_not_contains "other-project-srv" "$output" "mcp get list"
assert_not_contains "broken-entry" "$output" "mcp get list"
assert_not_contains "SECRETVALUE" "$output" "mcp get list"

log "case 3: the project is found through a symlinked path"
output=$(run_completion "$home" "$home/link/sub" 'claude mcp get \t')
assert_no_completion_errors "$output"
assert_contains "local-srv" "$output" "mcp get list via symlink"
assert_contains "project-srv" "$output" "mcp get list via symlink"

log "case 4: outside the project only user servers are offered"
output=$(run_completion "$home" "$home/elsewhere" 'claude mcp get \t')
assert_no_completion_errors "$output"
assert_contains "user-srv" "$output" "mcp get list outside the project"
assert_not_contains "local-srv" "$output" "mcp get list outside the project"
assert_not_contains "project-srv" "$output" "mcp get list outside the project"

for sub in remove login logout; do
    log "case 5.$sub: 'claude mcp $sub <TAB>' uses the same list"
    output=$(run_completion "$home" "$proj" "claude mcp $sub \\t")
    assert_no_completion_errors "$output"
    assert_contains "user-srv" "$output" "mcp $sub list"
    assert_contains "project-srv" "$output" "mcp $sub list"
done

log "case 6: CLAUDE_CONFIG_DIR moves .claude.json"
mkdir -p "$home/altconfig"
cat > "$home/altconfig/.claude.json" <<'JSON'
{ "mcpServers": { "alt-srv": { "command": "alt" } } }
JSON
output=$(run_completion "$home" "$home/elsewhere" 'claude mcp get \t' \
    "set env(CLAUDE_CONFIG_DIR) \"$home/altconfig\"")
assert_no_completion_errors "$output"
assert_contains "alt-srv" "$output" "mcp get list with CLAUDE_CONFIG_DIR"
assert_not_contains "user-srv" "$output" "mcp get list with CLAUDE_CONFIG_DIR"

log "case 7: a malformed .mcp.json does not hide the user and local servers"
printf '{ "mcpServers": { "project-srv": ' > "$proj/.mcp.json"
output=$(run_completion "$home" "$proj" 'claude mcp get \t')
assert_no_completion_errors "$output"
assert_contains "user-srv" "$output" "mcp get list with a broken .mcp.json"
assert_contains "local-srv" "$output" "mcp get list with a broken .mcp.json"

log "case 8: a malformed .claude.json does not hide the project servers"
printf '{ "mcpServers": { "project-srv": { "command": "ok" } } }' > "$proj/.mcp.json"
printf '{ "mcpServers": [1, 2' > "$home/.claude.json"
output=$(run_completion "$home" "$proj" 'claude mcp get \t')
assert_no_completion_errors "$output"
assert_contains "project-srv" "$output" "mcp get list with a broken .claude.json"

log "case 9: valid JSON of the wrong shape is not an error"
printf '[1, 2, 3]' > "$home/.claude.json"
printf '"just a string"' > "$proj/.mcp.json"
output=$(run_completion "$home" "$proj" 'claude mcp get \t')
assert_no_completion_errors "$output"

log "case 10: no config files at all is not an error"
rm -f "$home/.claude.json" "$proj/.mcp.json"
output=$(run_completion "$home" "$proj" 'claude mcp get \t')
assert_no_completion_errors "$output"

pass "MCP server name completion OK"
