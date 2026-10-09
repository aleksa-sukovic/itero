if ! command_exists codex || should_update; then
    log_info "Installing Codex CLI..."

    codex_installer="$(mktemp)"
    if ! curl -fsSL "https://chatgpt.com/codex/install.sh" -o "$codex_installer"; then
        rm -f "$codex_installer"
        log_warn "Failed to download the Codex installer"
        return 1
    fi

    # Keep the installer from modifying shell profiles managed by Itero
    if ! PATH="$HOME/.local/bin:$PATH" CODEX_NON_INTERACTIVE=1 sh "$codex_installer"; then
        rm -f "$codex_installer"
        log_warn "Failed to install Codex CLI"
        return 1
    fi

    rm -f "$codex_installer"
fi
