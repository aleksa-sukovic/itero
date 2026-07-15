#!/bin/bash

NERD_FONTS_VERSION="v3.4.0"
NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}"
NERD_FONTS=("JetBrainsMono")

CATPPUCCIN_CURSORS_VERSION="v2.0.0"
CATPPUCCIN_CURSORS_URL="https://github.com/catppuccin/cursors/releases/download/${CATPPUCCIN_CURSORS_VERSION}"

PHINGER_CURSORS_VERSION="3328966123"
PHINGER_CURSORS_URL="https://github.com/rehanzo/phinger-cursors-gruvbox-material/releases/download/${PHINGER_CURSORS_VERSION}/phinger-cursors-variants.tar.bz2"

ROSE_PINE_CURSOR_URL="https://github.com/rose-pine/cursors/releases/latest/download/BreezeX-RosePine-Linux.tar.xz"
ROSE_PINE_DAWN_CURSOR_URL="https://github.com/rose-pine/cursors/releases/latest/download/BreezeX-RosePineDawn-Linux.tar.xz"

get_fonts_dir() {
    if is_linux; then
        echo "$HOME/.local/share/fonts"
    elif is_macos; then
        echo "$HOME/Library/Fonts"
    fi
}

is_nerd_font_installed() {
    local font_name="$1"
    local fonts_dir="$(get_fonts_dir)"

    find "$fonts_dir" -type f -name "${font_name}*Nerd*.[ot]tf" 2>/dev/null | grep -q .
}

install_nerd_font() {
    local font_name="$1"
    local font_file="${font_name}.zip"
    local download_url="${NERD_FONTS_URL}/${font_file}"
    local fonts_dir="$(get_fonts_dir)"
    local tmp_dir="/tmp/nerd-fonts-${font_name}"

    if [[ -z "$fonts_dir" ]]; then
        log_warn "Unsupported OS for font installation"
        return 1
    fi

    if is_nerd_font_installed "$font_name" && ! should_update; then
        log_ok "${font_name} already installed"
        return 0
    fi

    mkdir -p "$fonts_dir"
    mkdir -p "$tmp_dir"

    log_info "Downloading ${font_name}..."
    if ! curl -fsSL "$download_url" -o "${tmp_dir}/${font_file}"; then
        log_warn "Failed to download ${font_name}"
        rm -rf "$tmp_dir"
        return 1
    fi

    log_info "Installing ${font_name}..."
    unzip -q -o "${tmp_dir}/${font_file}" -d "$tmp_dir"

    find "$tmp_dir" -type f \( -name "*.ttf" -o -name "*.otf" \) \
        ! -name "*Windows Compatible*" \
        -exec cp {} "$fonts_dir" \;

    rm -rf "$tmp_dir"
    log_ok "Installed ${font_name}"
}

install_phinger_gruvbox_material_cursors() {
    local icons_dir="$HOME/.local/share/icons"
    local cursor_names=(
        "phinger-cursors-gruvbox-material"
        "phinger-cursors-gruvbox-material-light"
    )
    local archive
    local tmp_dir

    if [[ -d "${icons_dir}/${cursor_names[0]}" && -d "${icons_dir}/${cursor_names[1]}" ]] && ! should_update; then
        return 0
    fi

    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/phinger-cursors-variants.tar.bz2"

    if ! curl -fsSL "$PHINGER_CURSORS_URL" -o "$archive"; then
        log_warn "Failed to download Phinger Gruvbox Material cursors"
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! tar -xjf "$archive" -C "$tmp_dir"; then
        log_warn "Failed to extract Phinger Gruvbox Material cursors"
        rm -rf "$tmp_dir"
        return 1
    fi

    mkdir -p "$icons_dir"
    for cursor_name in "${cursor_names[@]}"; do
        if [[ ! -d "$tmp_dir/$cursor_name" ]]; then
            log_warn "Missing ${cursor_name} in Phinger cursor archive"
            rm -rf "$tmp_dir"
            return 1
        fi

        rm -rf "$icons_dir/$cursor_name"
        mv "$tmp_dir/$cursor_name" "$icons_dir/$cursor_name"
    done

    rm -rf "$tmp_dir"
    log_ok "Phinger Gruvbox Material cursors installed"
}

install_rose_pine_cursors() {
    local cursor_names=("BreezeX-RosePine-Linux" "BreezeX-RosePineDawn-Linux")
    local cursor_urls=("$ROSE_PINE_CURSOR_URL" "$ROSE_PINE_DAWN_CURSOR_URL")
    local icons_dir="$HOME/.local/share/icons"
    local index

    for index in "${!cursor_names[@]}"; do
        local cursor_name="${cursor_names[$index]}"
        local target_dir="${icons_dir}/${cursor_name}"
        local tmp_dir
        local archive

        if [[ -d "$target_dir" ]] && ! should_update; then
            continue
        fi

        tmp_dir="$(mktemp -d)"
        archive="$tmp_dir/cursor.tar.xz"

        if ! curl -fsSL "${cursor_urls[$index]}" -o "$archive"; then
            log_warn "Failed to download ${cursor_name} cursors"
            rm -rf "$tmp_dir"
            continue
        fi

        if ! tar -xJf "$archive" -C "$tmp_dir" || [[ ! -d "$tmp_dir/$cursor_name" ]]; then
            log_warn "Invalid ${cursor_name} cursor archive"
            rm -rf "$tmp_dir"
            continue
        fi

        mkdir -p "$icons_dir"
        rm -rf "$target_dir"
        mv "$tmp_dir/$cursor_name" "$target_dir"
        rm -rf "$tmp_dir"
    done

    log_ok "Rosé Pine cursors installed"
}

install_catppuccin_cursors() {
    local icons_dir="$HOME/.local/share/icons"
    local flavors=("mocha" "macchiato" "frappe" "latte")
    local accents=("blue" "dark" "flamingo" "green" "lavender" "maroon" "mauve" "peach" "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow")

    mkdir -p "$icons_dir"

    for flavor in "${flavors[@]}"; do
        for accent in "${accents[@]}"; do
            local target_name="catppuccin-${flavor}-${accent}"
            local target_dir="${icons_dir}/${target_name}"

            if [[ -d "$target_dir" ]] && ! should_update; then
                continue
            fi

            local download_name="catppuccin-${flavor}-${accent}-cursors"
            local zip_url="${CATPPUCCIN_CURSORS_URL}/${download_name}.zip"
            local tmp_zip="/tmp/${download_name}.zip"

            if ! curl -fsSL "$zip_url" -o "$tmp_zip"; then
                log_warn "Failed to download ${target_name} cursors"
                continue
            fi

            unzip -q -o "$tmp_zip" -d "$icons_dir"
            rm -f "$tmp_zip"

            # Rename to match expected theme name
            if [[ "${icons_dir}/${download_name}" != "$target_dir" ]]; then
                rm -rf "$target_dir"
                mv "${icons_dir}/${download_name}" "$target_dir"
            fi
        done
    done

    log_ok "Catppuccin cursors installed"
}

if is_linux; then
    log_info "Installing fonts..."

    for font in "${NERD_FONTS[@]}"; do
        install_nerd_font "$font"
    done

    install_catppuccin_cursors
    install_phinger_gruvbox_material_cursors
    install_rose_pine_cursors

    if command_exists fc-cache; then
        log_info "Refreshing font cache..."
        fc-cache -f
        log_ok "Font cache refreshed"
    fi

    log_ok "Font installation complete"
elif is_macos; then
    log_info "Installing Nerd Fonts..."

    for font in "${NERD_FONTS[@]}"; do
        install_nerd_font "$font"
    done

    log_ok "Nerd Fonts installation complete"
    log_info "You may need to restart applications to see the new fonts"
fi
