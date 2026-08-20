#!/bin/bash

choice=$(printf "Shell\nPython REPL\nNode REPL" | fzf --reverse --prompt="Open > " --no-info)

case "$choice" in
  "Shell")       exec "$SHELL" ;;
  "Python REPL") exec python3 ;;
  "Node REPL")   exec node ;;
  *)             exit 0 ;;
esac
