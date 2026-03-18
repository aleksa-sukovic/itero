init_local "$ITERO_CONFIG/shell/zshrc.local" "$HOME/.zshrc.local"
init_local "$ITERO_CONFIG/shell/functions.local" "$HOME/.functions.local"

link_file "$HOME/.zshrc.local" "$ITERO_CONFIG/shell/zshrc.local"
link_file "$HOME/.functions.local" "$ITERO_CONFIG/shell/functions.local"

link_file "$ITERO_CONFIG/shell/zshrc" "$HOME/.zshrc"
link_file "$ITERO_CONFIG/shell/functions" "$HOME/.functions"

desired_shell="$(command -v zsh)"

if [ -z "$desired_shell" ]; then
    log_warn "zsh not found"
    return 1
fi

if [ "$SHELL" != "$desired_shell" ]; then
    chsh -s "$desired_shell"
    log_ok "Set zsh as default shell (takes effect on next login)"
fi
