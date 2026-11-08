if is_linux; then
    dnf_install k9s
elif is_macos; then
    brew_install derailed/k9s/k9s
fi

if is_macos; then
    k9s_config_dir="${K9S_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/Library/Application Support}/k9s}"
else
    k9s_config_dir="${K9S_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/k9s}"
fi

link_file "$ITERO_CONFIG/k9s/config.yaml" "$k9s_config_dir/config.yaml"
link_file "$ITERO_CONFIG/k9s/skins/transparent.yaml" "$k9s_config_dir/skins/transparent.yaml"
