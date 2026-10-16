if ! command_exists herdr || should_update; then
    log_info "Installing Herdr..."

    herdr_installer="$(mktemp)"
    if ! curl -fsSL "https://herdr.dev/install.sh" -o "$herdr_installer"; then
        rm -f "$herdr_installer"
        log_warn "Failed to download the Herdr installer"
        return 1
    fi

    if ! HERDR_INSTALL_DIR="$HOME/.local/bin" sh "$herdr_installer"; then
        rm -f "$herdr_installer"
        log_warn "Failed to install Herdr"
        return 1
    fi

    rm -f "$herdr_installer"
fi

PATH="$HOME/.local/bin:$PATH"

link_file "$ITERO_CONFIG/herdr/config.toml" "$HOME/.config/herdr/config.toml" || return 1

mkdir -p "${CODEX_HOME:-$HOME/.codex}" "${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}" || return 1

# Refresh the integrations bundled with the installed Herdr release
herdr integration install codex || return 1
herdr integration install pi || return 1
