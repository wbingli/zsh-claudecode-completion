# zsh-claudecode-completion plugin
# Minimal zsh completion for Claude Code CLI
# https://github.com/anthropics/claude-code

# Get the directory where this plugin is located
local _plugin_dir="${0:A:h}"

# Determine cache directory (Oh My Zsh or fallback)
local _cache_dir="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}/completions"

# Create cache directory if it doesn't exist
[[ -d "$_cache_dir" ]] || mkdir -p "$_cache_dir"

# Copy completion script to cache directory
# This avoids fpath duplication issues when plugin dir is symlinked
if [[ -f "$_plugin_dir/_claude" ]]; then
  cp "$_plugin_dir/_claude" "$_cache_dir/_claude"
fi

# Ensure cache directory is in fpath (Oh My Zsh usually adds this, but just in case)
if [[ -z "${fpath[(r)$_cache_dir]}" ]]; then
  fpath=("$_cache_dir" $fpath)
fi
