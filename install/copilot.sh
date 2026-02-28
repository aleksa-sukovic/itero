if is_linux; then
    if ! command_exists copilot || should_update; then
        curl -fsSL https://gh.io/copilot-install | bash
    fi
fi
