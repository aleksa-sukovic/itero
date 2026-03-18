if is_linux; then
    dnf_install neovim
elif is_macos; then
    brew_install neovim
fi

link_mirror "$ITERO_CONFIG/nvim" "$HOME/.config/nvim"
