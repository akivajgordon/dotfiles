#!/bin/bash

direction="$1"  # either -h or -v

selected=$(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_title}' \
  | fzf --prompt="Select pane to move into current: " \
  | awk '{print $1}')

[ -n "$selected" ] && tmux join-pane -s "$selected" -t ! "$direction"
