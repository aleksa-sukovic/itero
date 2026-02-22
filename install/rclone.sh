#!/bin/bash

if is_linux; then
    log_info "Setting up Google Drive sync..."

    # Install/update rclone (script also handles updates)
    curl -fsSL https://rclone.org/install.sh | sudo bash &>/dev/null

    # verify rclone is available
    if ! command_exists rclone; then
        log_warn "Failed to install rclone"
        return 1
    fi

    # Configure remote if not present
    if ! rclone listremotes 2>/dev/null | grep -q "^gdrive:$"; then
        log_info "No 'gdrive' remote found. Starting rclone config..."
        log_info "  Name the remote: gdrive"
        log_info "  Type: Google Drive"
        log_info "  Scope: Full access"
        echo ""
        rclone config

        if ! rclone listremotes 2>/dev/null | grep -q "^gdrive:$"; then
            log_warn "Remote 'gdrive' not configured. Skipping sync setup."
            return 0
        fi
    fi

    # Directories
    mkdir -p "${GDRIVE_HOME:-$HOME/Drive}"
    mkdir -p "$HOME/.local/state/itero"
    mkdir -p "$HOME/.config/systemd/user"

    # Link config and systemd units
    link_file "$ITERO_CONFIG/rclone/filters.txt" "$HOME/.config/rclone/filters.txt"
    link_file "$ITERO_CONFIG/rclone/itero-gdrive.service" "$HOME/.config/systemd/user/itero-gdrive.service"
    link_file "$ITERO_CONFIG/rclone/itero-gdrive.timer" "$HOME/.config/systemd/user/itero-gdrive.timer"

    # Initial bisync (establishes baseline)
    if [ ! -f "$HOME/.local/state/itero/gdrive-initialized" ]; then
        log_info "Running initial bisync (this may take a while)..."
        rclone bisync "gdrive:" "${GDRIVE_HOME:-$HOME/Drive}" \
            --resync \
            --create-empty-src-dirs \
            --filter-from "$HOME/.config/rclone/filters.txt" \
            --drive-skip-gdocs \
            --verbose

        touch "$HOME/.local/state/itero/gdrive-initialized"
        log_ok "Initial bisync complete"
    fi

    # Enable and start timer
    systemctl --user daemon-reload
    systemctl --user enable --now itero-gdrive.timer
    log_ok "Google Drive sync enabled (every 15 minutes)"
fi
