#!/bin/bash
GDRIVE_HOME="${GDRIVE_HOME:-$HOME/Drive}"
REMOTE="gdrive"
FILTER_FILE="$HOME/.config/rclone/filters.txt"
LOG_FILE="$HOME/.local/state/itero/gdrive-sync.log"
BISYNC_DIR="$HOME/.cache/rclone/bisync"

# bisync needs a snapshot from the last run to detect changes.
# If missing (first run or crash), add --resync to build it from scratch.
extra_flags=()
if ! ls "$BISYNC_DIR/${REMOTE}_"*.path1.lst &>/dev/null; then
    echo "No bisync snapshot found, running with --resync..." >> "$LOG_FILE"
    extra_flags+=("--resync")
fi

exec rclone bisync "${REMOTE}:" "$GDRIVE_HOME" \
    "${extra_flags[@]}" \
    --filter-from "$FILTER_FILE" \
    --create-empty-src-dirs \
    --conflict-resolve newer \
    --conflict-loser num \
    --conflict-suffix .conflict \
    --resilient \
    --recover \
    --no-update-dir-modtime \
    --max-lock 2m \
    --drive-skip-gdocs \
    --verbose \
    --log-file "$LOG_FILE"
