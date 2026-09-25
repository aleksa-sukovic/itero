# Install the latest stable ngrok agent.
install_ngrok() {
    local archive
    local tmp_dir

    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/ngrok.tgz"

    log_info "Installing ngrok..."
    if ! curl -fsSL \
        "https://bin.ngrok.com/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz" \
        -o "$archive"; then
        rm -rf "$tmp_dir"
        log_warn "Failed to download ngrok"
        return 1
    fi

    if ! tar -xzf "$archive" -C "$tmp_dir"; then
        rm -rf "$tmp_dir"
        log_warn "Failed to extract ngrok"
        return 1
    fi

    install -Dm755 "$tmp_dir/ngrok" "$HOME/.local/bin/ngrok"
    rm -rf "$tmp_dir"
    log_ok "Installed ngrok"
}

if ! is_linux; then
    return 0
fi

dnf_install ttyd

if ! command_exists ngrok || should_update; then
    install_ngrok
fi
