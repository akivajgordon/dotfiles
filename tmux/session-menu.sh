#!/bin/bash

current=$(tmux display-message -p '#{session_name}')
sessions=()

while IFS= read -r s; do
    [ "$s" != "$current" ] && sessions+=("$s")
done < <(tmux list-sessions -F "#{session_name}")

# No other sessions? Do nothing.
[ ${#sessions[@]} -eq 0 ] && exit 0

items=()
for s in "${sessions[@]}"; do
    esc=$(printf "%s" "$s" | sed 's/"/\\"/g')
    items+=("$esc" "" "switch-client -t $esc")
done

tmux display-menu -x 0 -y S -T "Sessions" "${items[@]}"
