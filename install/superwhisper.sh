#!/bin/bash

if ! is_linux; then
    return 0
fi

# N.B. Superwhisper replaces files on save, so link the directory; only preferences.json is tracked.
config_dir="${SUPERWHISPER_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/superwhisper}"
link_file "$ITERO_CONFIG/superwhisper" "$config_dir" || return 1

if [[ ! -x "$HOME/.local/bin/superwhisper" ]] || should_update; then
    (
        tmp_dir="$(mktemp -d)" || exit 1
        trap 'rm -rf "$tmp_dir"' EXIT

        version="$ITERO_APP_VERSION_SUPERWHISPER"
        url="https://github.com/superultrainc/superwhisper-linux-releases/releases/download/v$version/superwhisper-omarchy-$(uname -m)-$version.tar.zst"

        log_info "Installing Superwhisper $version..."
        curl -fsSL "$url" -o "$tmp_dir/release.tar.zst" || exit 1
        tar --zstd -xf "$tmp_dir/release.tar.zst" --strip-components=1 -C "$tmp_dir" || exit 1

        source "$tmp_dir/dependencies.sh" || exit 1
        sw_dependencies || exit 1

        # N.B. Accept RPM Fusion's ffmpeg instead of the conflicting ffmpeg-free package.
        if package_exists ffmpeg; then
            packages=("${packages[@]/ffmpeg-free/ffmpeg}")
        fi

        dnf_install "${packages[@]}" || exit 1

        # N.B. Use Fedora's Python; Mise's Python cannot see the system GTK bindings.
        PATH="/usr/bin:$PATH" SW_SKIP_PACKAGES=1 bash "$tmp_dir/install.sh"
    ) || return 1
fi

# Disable automatic update; keeps Itero's configured version.
systemctl --user disable --now superwhisper-update.timer || return 1
