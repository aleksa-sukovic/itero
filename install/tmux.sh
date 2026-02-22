if is_linux; then
    dnf_install tmux
fi

link_file "$ITERO_CONFIG/tmux/tmux.conf" "$HOME/.tmux.conf"
