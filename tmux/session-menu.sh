#!/bin/bash

current=$(tmux display-message -p '#{session_name}')

# Get list of sessions excluding current
sessions=$(tmux list-sessions -F "#{session_name}" | grep -v "^${current}$")

# Use fzf to select or create session
# --print-query prints what user typed, then the selection (if any)
result=$(echo "$sessions" | fzf \
    --print-query \
    --prompt="Session: " \
    --reverse \
    --no-info)

# Exit if user cancelled (Ctrl-C or Esc)
[ $? -ne 0 ] && exit 0

# Parse result: first line is query, second line (if exists) is selection
query=$(echo "$result" | sed -n '1p')
selection=$(echo "$result" | sed -n '2p')

# Use selection if it exists, otherwise use query
target="${selection:-$query}"

# Exit if empty
[ -z "$target" ] && exit 0

# Check if session exists
if tmux has-session -t "$target" 2>/dev/null; then
    # Session exists, switch to it
    tmux switch-client -t "$target"
else
    # Session doesn't exist, create and switch to it
    tmux new-session -d -s "$target" -c "$HOME"
    tmux switch-client -t "$target"
fi
