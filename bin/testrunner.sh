#!/bin/bash
set -e

# Check if we're in a tmux session
if [ -z "$TMUX" ]; then
    echo "Error: Not in a tmux session"
    exit 1
fi

# Parse arguments
FORCE_PICK=false
FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --pick)
            FORCE_PICK=true
            shift
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

# Find project root by looking for package.json
find_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/package.json" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    echo "Error: Could not find package.json" >&2
    return 1
}

PROJECT_ROOT=$(find_project_root)
if [ $? -ne 0 ]; then
    exit 1
fi

SCHEME_FILE="$PROJECT_ROOT/.testrunner-scheme"

# Get test scripts from package.json
get_test_scripts() {
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed" >&2
        exit 1
    fi

    jq -r '.scripts | to_entries | .[] | select(.key | contains("test")) | .key' "$PROJECT_ROOT/package.json"
}

# Show scheme picker with fzf in tmux popup
pick_scheme() {
    local test_scripts=$(get_test_scripts)

    if [ -z "$test_scripts" ]; then
        echo "Error: No test scripts found in package.json" >&2
        exit 1
    fi

    # Count test scripts
    local script_count=$(echo "$test_scripts" | wc -l | tr -d ' ')

    # If only one test script, use it automatically (unless forcing pick)
    if [ "$script_count" -eq 1 ] && [ "$FORCE_PICK" = false ]; then
        echo "$test_scripts"
        return 0
    fi

    # Load current scheme for highlighting
    local current_scheme=""
    if [ -f "$SCHEME_FILE" ]; then
        current_scheme=$(cat "$SCHEME_FILE")
    fi

    # Build fzf input with commands preview and current marker
    local fzf_input=""
    while IFS= read -r script; do
        local cmd=$(jq -r ".scripts[\"$script\"]" "$PROJECT_ROOT/package.json")
        local marker=""
        if [ "$script" = "$current_scheme" ]; then
            marker="● "
        else
            marker="  "
        fi
        fzf_input+="${marker}${script} → ${cmd}\n"
    done <<< "$test_scripts"

    # Show picker in tmux popup
    # Use a temp file to capture fzf output (tmux popup doesn't reliably capture stdout)
    local temp_file=$(mktemp)

    tmux display-popup -E -w 80% -h 60% \
        "printf '%b' '$fzf_input' | fzf --ansi \
             --prompt='Select test scheme: ' \
             --header='Current scheme marked with ●' \
             --preview='echo {}' \
             --preview-window=hidden > '$temp_file'"

    local selected=$(cat "$temp_file")
    rm "$temp_file"

    if [ -z "$selected" ]; then
        # User cancelled, use current scheme or fallback to first
        if [ -n "$current_scheme" ]; then
            echo "$current_scheme"
        else
            echo "$test_scripts" | head -n 1
        fi
        return 0
    fi

    # Extract just the script name (remove marker and command preview)
    # Split on " → " and take first part, then trim leading whitespace and markers
    echo "$selected" | sed -E 's/ →.*//' | sed -E 's/^[● ]+//'
}

# Load or pick scheme
SCHEME=""
if [ "$FORCE_PICK" = true ] || [ ! -f "$SCHEME_FILE" ]; then
    SCHEME=$(pick_scheme)
    echo "$SCHEME" > "$SCHEME_FILE"

    # If just picking, exit after storing
    if [ "$FORCE_PICK" = true ]; then
        echo "Test scheme set to: $SCHEME"
        exit 0
    fi
else
    SCHEME=$(cat "$SCHEME_FILE")
    # Validate that scheme still exists in package.json
    if ! get_test_scripts | grep -q "^${SCHEME}$"; then
        echo "Warning: Stored scheme '$SCHEME' no longer exists, picking new one" >&2
        SCHEME=$(pick_scheme)
        echo "$SCHEME" > "$SCHEME_FILE"
    fi
fi

# Build the test command
if [ -n "$FILE" ]; then
    TEST_CMD="npm run $SCHEME -- '${FILE}'"
else
    TEST_CMD="npm run $SCHEME"
fi

# Run in a new tmux pane (vertical split)
tmux split-window -v -c "$PROJECT_ROOT" "
    echo 'Running: $TEST_CMD'
    echo ''
    $TEST_CMD
    echo ''
    echo 'Press Enter to close this pane...'
    read
"
