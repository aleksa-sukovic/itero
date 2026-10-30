#!/bin/bash

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/voxtype"

if is_linux; then
    platform="linux"
    if [[ "$(uname -m)" != "x86_64" ]]; then
        log_warn "Voxtype's Fedora package is only available for x86_64"
        return 1
    fi

    if ! package_exists voxtype || should_update; then
        version="$ITERO_APP_VERSION_VOXTYPE"
        url="https://github.com/peteonrails/voxtype/releases/download/v$version/voxtype-$version-1.x86_64.rpm"
        sudo dnf install -y "$url" || return 1
    fi

    if [[ ! -x "$HOME/.local/bin/eitype" ]] || should_update; then
        if ! command_exists mise || ! mise where rust &>/dev/null; then
            log_warn "Mise-managed Rust is required to install eitype; run ITC=mise itero first"
            return 1
        fi
        mise exec -- cargo install --locked --root "$HOME/.local" eitype || return 1
    fi

    sudo voxtype setup onnx --enable || return 1
elif is_macos; then
    platform="macos"
    brew_install --cask peteonrails/voxtype/voxtype || return 1
else
    return 0
fi

# N.B. We link the directory because Voxtype replaces its config file when saving.
link_file "$ITERO_CONFIG/voxtype/$platform" "$config_dir" || return 1

model="$(yq -p=toml -oy -r '.parakeet.model' "$config_dir/config.toml")" || return 1
voxtype setup --download --model "$model" || return 1

if is_linux; then
    link_file "$ITERO_CONFIG/voxtype/environment.conf" "$HOME/.config/systemd/user/voxtype.service.d/environment.conf" || return 1
    systemctl --user daemon-reload || return 1
    systemctl --user enable voxtype.service || return 1
    systemctl --user restart voxtype.service || return 1
elif is_macos; then
    voxtype setup launchd || return 1
    log_info "Open Voxtype to grant macOS microphone and accessibility permissions."
fi
