#!/bin/bash
#
# Test for plugin and marketplace value completion (issue #228):
#   - installed plugins for `plugin configure`, `details`, `enable`,
#     `disable`, `uninstall`, `update` and as a `plugin eval` target
#   - installable plugins for `plugin install`, from the manifests the
#     marketplaces cache
#   - marketplace names for `plugin marketplace remove` / `update`
#
# Everything is read from a fake $HOME/.claude/plugins. The fixtures mix in
# the older installed_plugins.json format and several malformed entries,
# which must not hide the valid ones.

set -e
TEST_NAME=test-plugin-values
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

require_common_deps
require_dep jq

home=$(make_test_home)
trap 'rm -rf "$home"' EXIT

# $2 is appended to every plugin and marketplace name, to tell a second
# config directory apart. Names deliberately share no prefix, so that a
# TAB lists them instead of inserting the common part.
write_fixtures() {
    local plugins_dir="$1/plugins" tag="$2"
    mkdir -p "$plugins_dir/marketplaces/one-market/.claude-plugin" \
             "$plugins_dir/marketplaces/two-market/.claude-plugin"
    # `legacy` uses the older format: one install object instead of a list.
    cat > "$plugins_dir/installed_plugins.json" <<JSON
{
  "version": 2,
  "plugins": {
    "alpha${tag}@one-market": [{ "scope": "user", "version": "1.2.3" }],
    "oops${tag}@one-market": ["not an install"],
    "beta${tag}@two-market": [{ "scope": "project", "version": "0.9.0" }],
    "worse${tag}@one-market": "just a string",
    "legacy${tag}@one-market": { "version": "0.1.0" },
    "here${tag}@two-market": [{ "scope": "project", "projectPath": "$home/proj", "version": "2.0.0" }],
    "elsewhere${tag}@two-market": [{ "scope": "local", "projectPath": "$home/another-project", "version": "3.0.0" }]
  }
}
JSON
    cat > "$plugins_dir/known_marketplaces.json" <<JSON
{
  "one-market${tag}": { "source": { "source": "github", "repo": "org/one" } },
  "bad-market${tag}": "just a string",
  "two-market${tag}": { "source": { "source": "git", "url": "https://example.com/two.git" } },
  "odd-market${tag}": { "source": "not an object" }
}
JSON
    cat > "$plugins_dir/marketplaces/one-market/.claude-plugin/marketplace.json" <<JSON
{
  "name": "one-market",
  "plugins": [
    { "name": "alpha${tag}", "description": "Alpha plugin text" },
    "junk entry",
    { "description": "entry without a name" },
    { "name": "gamma${tag}", "description": ["not", "a", "string"] }
  ]
}
JSON
    cat > "$plugins_dir/marketplaces/two-market/.claude-plugin/marketplace.json" <<JSON
{ "plugins": [{ "name": "beta${tag}", "description": "Beta plugin text" }] }
JSON
}
write_fixtures "$home/.claude" ""

work="$home/work"
mkdir -p "$work/some-dir"
complete() { run_completion "$home" "$work" "$1" "${2:-}"; }

log "case 1: installed plugins, including the older single-object format"
output=$(complete 'claude plugin enable \t')
assert_no_completion_errors "$output"
for id in alpha@one-market beta@two-market legacy@one-market; do
    assert_contains "$id" "$output" "installed plugin list"
done
assert_contains "1.2.3" "$output" "installed plugin list"

log "case 2: a malformed install entry does not hide the others"
assert_not_contains "oops@" "$output" "installed plugin list"
assert_not_contains "worse@" "$output" "installed plugin list"

log "case 2b: a project-scope install is only offered inside its project"
assert_not_contains "here@" "$output" "installed plugin list outside the project"
assert_not_contains "elsewhere@" "$output" "installed plugin list outside the project"
mkdir -p "$home/proj/.git" "$home/proj/sub"
output=$(run_completion "$home" "$home/proj/sub" 'claude plugin enable \t')
assert_no_completion_errors "$output"
assert_contains "here@two-market" "$output" "installed plugin list inside the project"
assert_contains "alpha@one-market" "$output" "installed plugin list inside the project"
assert_not_contains "elsewhere@" "$output" "installed plugin list inside the project"

log "case 2c: 'claude plugin list --data-size <TAB>' offers installed plugins"
output=$(complete 'claude plugin list --data-size \t')
assert_no_completion_errors "$output"
assert_contains "alpha@one-market" "$output" "plugin list --data-size list"

for sub in configure details disable uninstall remove update; do
    log "case 3.$sub: 'claude plugin $sub <TAB>' offers installed plugins"
    output=$(complete "claude plugin $sub \\t")
    assert_no_completion_errors "$output"
    assert_contains "alpha@one-market" "$output" "plugin $sub list"
    assert_contains "beta@two-market" "$output" "plugin $sub list"
done

log "case 4: 'claude plugins enable <TAB>' (alias) offers the same list"
output=$(complete 'claude plugins enable \t')
assert_no_completion_errors "$output"
assert_contains "alpha@one-market" "$output" "plugins enable list"

log "case 5: 'claude plugin install <TAB>' offers plugins from every manifest"
output=$(complete 'claude plugin install \t')
assert_no_completion_errors "$output"
assert_contains "alpha@one-market" "$output" "installable plugin list"
assert_contains "Alpha plugin text" "$output" "installable plugin list"
assert_contains "beta@two-market" "$output" "installable plugin list"
# A non-string description must not drop the plugin.
assert_contains "gamma@one-market" "$output" "installable plugin list"
assert_not_contains "junk entry" "$output" "installable plugin list"
assert_not_contains "legacy@" "$output" "installable plugin list"

log "case 6: 'claude plugin i <TAB>' (alias) offers the same list"
output=$(complete 'claude plugin i \t')
assert_no_completion_errors "$output"
assert_contains "beta@two-market" "$output" "plugin i list"

log "case 7: a manifest that is not valid JSON does not hide the others"
mkdir -p "$home/.claude/plugins/marketplaces/broken-market/.claude-plugin"
printf '{ "plugins": [ { "name": "half' \
    > "$home/.claude/plugins/marketplaces/broken-market/.claude-plugin/marketplace.json"
output=$(complete 'claude plugin install \t')
assert_no_completion_errors "$output"
assert_contains "alpha@one-market" "$output" "installable plugin list with a broken manifest"
assert_contains "beta@two-market" "$output" "installable plugin list with a broken manifest"
assert_not_contains "broken-market" "$output" "installable plugin list with a broken manifest"

for sub in remove rm update; do
    log "case 8.$sub: 'claude plugin marketplace $sub <TAB>' offers marketplaces"
    output=$(complete "claude plugin marketplace $sub \\t")
    assert_no_completion_errors "$output"
    assert_contains "one-market" "$output" "marketplace $sub list"
    assert_contains "two-market" "$output" "marketplace $sub list"
    # Its source is malformed, but the marketplace itself is still known.
    assert_contains "odd-market" "$output" "marketplace $sub list"
    assert_not_contains "bad-market" "$output" "marketplace $sub list"
done

log "case 9: 'claude plugin eval <TAB>' offers init, installed plugins and paths"
output=$(complete 'claude plugin eval \t')
assert_no_completion_errors "$output"
assert_not_contains "bad option" "$output" "plugin eval candidates"
assert_contains "init" "$output" "plugin eval candidates"
assert_contains "alpha@one-market" "$output" "plugin eval candidates"
assert_contains "some-dir" "$output" "plugin eval candidates"

log "case 10: CLAUDE_CONFIG_DIR replaces ~/.claude"
write_fixtures "$home/altconfig" "-alt"
alt_env="set env(CLAUDE_CONFIG_DIR) \"$home/altconfig\""
output=$(complete 'claude plugin enable \t' "$alt_env")
assert_no_completion_errors "$output"
assert_contains "alpha-alt@one-market" "$output" "installed list with CLAUDE_CONFIG_DIR"
assert_not_contains "alpha@one-market" "$output" "installed list with CLAUDE_CONFIG_DIR"
output=$(complete 'claude plugin install \t' "$alt_env")
assert_no_completion_errors "$output"
assert_contains "beta-alt@two-market" "$output" "installable list with CLAUDE_CONFIG_DIR"
output=$(complete 'claude plugin marketplace remove \t' "$alt_env")
assert_no_completion_errors "$output"
assert_contains "one-market-alt" "$output" "marketplace list with CLAUDE_CONFIG_DIR"

log "case 11: malformed or missing files are not an error"
mkdir -p "$home/brokenconfig/plugins" "$home/emptyconfig"
printf '{ "plugins": {' > "$home/brokenconfig/plugins/installed_plugins.json"
printf '[1, 2' > "$home/brokenconfig/plugins/known_marketplaces.json"
for dir in brokenconfig emptyconfig; do
    env_line="set env(CLAUDE_CONFIG_DIR) \"$home/$dir\""
    for keys in 'claude plugin enable \t' 'claude plugin install \t' \
                'claude plugin marketplace remove \t' 'claude plugin eval \t'; do
        output=$(complete "$keys" "$env_line")
        assert_no_completion_errors "$output"
        assert_not_contains "bad option" "$output" "completion with $dir"
    done
done

pass "plugin and marketplace value completion OK"
