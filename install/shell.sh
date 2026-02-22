init_local "$ITERO_CONFIG/shell/zshrc.local" "$HOME/.zshrc.local"
init_local "$ITERO_CONFIG/shell/functions.local" "$HOME/.functions.local"

link_file "$ITERO_CONFIG/shell/zshrc" "$HOME/.zshrc"
link_file "$ITERO_CONFIG/shell/functions" "$HOME/.functions"

if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    log_ok "Set zsh as default shell (takes effect on next login)"
fi
