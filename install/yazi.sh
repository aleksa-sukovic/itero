if is_linux; then
    yazi_dir="$HOME/.local/share/yazi-nightly"

    if [ ! -x "$yazi_dir/yazi" ] || [ ! -x "$yazi_dir/ya" ] || should_update; then
        yazi_archive="yazi-$(uname -m)-unknown-linux-gnu.zip"
        yazi_url="https://github.com/sxyazi/yazi/releases/download/nightly/$yazi_archive"
        yazi_tmp_dir="$(mktemp -d)"

        log_info "Installing Yazi nightly..."
        if ! curl --fail --location --silent --show-error "$yazi_url" \
            -o "$yazi_tmp_dir/$yazi_archive" \
            || ! unzip -q "$yazi_tmp_dir/$yazi_archive" -d "$yazi_tmp_dir" \
            || [ ! -x "$yazi_tmp_dir/${yazi_archive%.zip}/yazi" ] \
            || [ ! -x "$yazi_tmp_dir/${yazi_archive%.zip}/ya" ]; then
            rm -rf "$yazi_tmp_dir"
            log_warn "Failed to install Yazi nightly"
            return 1
        fi

        rm -rf "$yazi_dir"
        mkdir -p "$(dirname "$yazi_dir")"
        mv "$yazi_tmp_dir/${yazi_archive%.zip}" "$yazi_dir"
        rm -rf "$yazi_tmp_dir"
        log_ok "Installed Yazi nightly"
    fi

    mkdir -p "$HOME/.local/bin"
    ln -nsf "$yazi_dir/yazi" "$HOME/.local/bin/yazi"
    ln -nsf "$yazi_dir/ya" "$HOME/.local/bin/ya"

    install_desktop "$ITERO_CONFIG/yazi/yazi.desktop"
elif is_macos; then
    brew_install yazi
fi

rm -f "$HOME/.config/yazi/theme.toml"
link_mirror "$ITERO_CONFIG/yazi" "$HOME/.config/yazi"

if should_update; then
    if ! ya pkg upgrade --discard; then
        log_warn "Failed to upgrade Yazi packages"
        return 1
    fi
fi

if file_has_changed "$ITERO_CONFIG/yazi/package.toml" true; then
    if ! ya pkg install; then
        log_warn "Failed to install yazi packages"
        return 1
    fi
fi
