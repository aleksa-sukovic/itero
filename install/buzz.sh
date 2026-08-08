#!/bin/bash

get_buzz_asset_url() {
    buzz_repository="block/buzz"
    buzz_asset_suffix="_amd64.AppImage"
    curl -fsSL "https://api.github.com/repos/$buzz_repository/releases/latest" |
        jq -r --arg suffix "$buzz_asset_suffix" \
            '[.assets[] | select(.name | endswith($suffix)) | .browser_download_url] | first // empty'
}

install_buzz_appimage() {
    local asset_url="$1"
    local buzz_path="$2"
    local tmp_path

    log_info "Installing Buzz..."
    tmp_path="$(mktemp)"

    if ! curl -fL --progress-bar "$asset_url" -o "$tmp_path"; then
        rm -f "$tmp_path"
        return 1
    fi

    mkdir -p "$(dirname "$buzz_path")"
    chmod +x "$tmp_path"
    mv "$tmp_path" "$buzz_path"
    log_ok "Installed Buzz"
}

if is_linux; then
    buzz_path="$HOME/.local/share/buzz/Buzz.AppImage"
    buzz_bin="$HOME/.local/bin/buzz"

    if [ ! -x "$buzz_path" ] || should_update; then
        if ! command_exists jq; then
            log_warn "jq is required to install Buzz"
            exit 1
        fi

        asset_url="$(get_buzz_asset_url)"
        if [ -z "$asset_url" ]; then
            log_warn "No x86_64 Buzz AppImage found in the latest release"
            exit 1
        fi

        install_buzz_appimage "$asset_url" "$buzz_path" || exit 1
    fi

    mkdir -p "$(dirname "$buzz_bin")"
    ln -nsf "$buzz_path" "$buzz_bin"
    install_desktop "$ITERO_CONFIG/buzz/buzz.desktop"
elif is_macos; then
    brew_install --cask block-buzz
fi
