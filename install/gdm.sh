if ! is_linux; then
    return 0
fi

log_info "Setting up GDM..."

# Remove Fedora logo from the GDM login screen
local gdm_override="/etc/dconf/db/gdm.d/99-itero-no-logo"
local gdm_content="[org/gnome/login-screen]\nlogo=''"

echo -e "$gdm_content" | sudo tee "$gdm_override" >/dev/null
sudo dconf update
log_ok "Removed Fedora logo from login screen"

# Remove Fedora logo from the Plymouth boot/logout splash
local watermark="/usr/share/plymouth/themes/spinner/watermark.png"
local watermark_bak="/usr/share/plymouth/themes/spinner/watermark.bak.png"

if [[ -f "$watermark" ]] && [[ ! -f "$watermark_bak" ]]; then
    sudo cp "$watermark" "$watermark_bak"
    sudo magick -size 1x1 xc:transparent "$watermark"
    sudo dracut --force --regenerate-all
    log_ok "Removed Fedora logo from Plymouth splash"
fi

# Install Plymouth theme
local plymouth_tar="$ITERO_CONFIG/gdm/plymouth-theme.tar.xz"
local theme_name="dotLockG"
local theme_dest="/usr/share/plymouth/themes/$theme_name"

if [[ ! -d "$theme_dest" ]]; then
    sudo mkdir -p "$theme_dest"
    sudo tar -xJf "$plymouth_tar" -C "$theme_dest"

    sudo plymouth-set-default-theme "$theme_name" -R
    log_ok "Installed Plymouth theme: $theme_name"
fi

# Set user avatar
local avatar_src="$ITERO_CONFIG/gdm/avatar.jpg"
local avatar_dest="/var/lib/AccountsService/icons/$USER"

if [[ -f "$avatar_src" ]]; then
    if file_has_changed "$avatar_src" || should_update; then
        sudo cp "$avatar_src" "$avatar_dest"
        sudo chmod 644 "$avatar_dest"

        sudo busctl call org.freedesktop.Accounts \
            "/org/freedesktop/Accounts/User$(id -u)" \
            org.freedesktop.Accounts.User SetIconFile s "$avatar_dest"

        log_ok "User avatar updated"
    fi
fi

log_ok "GDM setup complete"
