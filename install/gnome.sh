if ! is_linux; then
    return 0
fi

log_info "Setting up GNOME..."

GNOME_EXTENSIONS=(
    "custom-hot-corners-extended@G-dH.github.com"
    "gsconnect@andyholmes.github.io"
    "lockkeys@vaina.lt"
    "night-light-slider-updated@vilsbeg.codeberg.org"
    "vicinae@dagimg-dot"
)

# Install Extension Manager for managing extensions via GUI
flatpak_install "com.mattjakeman.ExtensionManager"

# Setup tiling window management
local pop_shell_repo="https://aleksa-sukovic:$GITHUB_TOKEN@github.com/aleksa-sukovic/itero-wm.git"
local pop_shell_dir="$HOME/.local/share/itero-sources/itero-wm"
local pop_shell_dest="$HOME/.local/share/gnome-shell/extensions/pop-shell@system76.com"

if [[ ! -d "$pop_shell_dir" ]]; then
    git clone -b master "$pop_shell_repo" "$pop_shell_dir"
fi

if [[ ! -d "$pop_shell_dest" ]] || should_update; then
    cd "$pop_shell_dir"
    git pull --ff-only
    make
    make install
    cd "$ITERO_PATH"
    log_ok "Installed Pop Shell from fork"
fi

# Install system-wide schemas for dconf settings to work
sudo cp "$pop_shell_dir/schemas/org.gnome.shell.extensions.pop-shell.gschema.xml" \
    /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

rm -f "$HOME/.config/pop-shell/config.json"
link_file "$ITERO_CONFIG/gnome/pop-shell.json" "$HOME/.config/pop-shell/config.json"

# Install extensions that are not yet installed
for ext in "${GNOME_EXTENSIONS[@]}"; do
    if ! gnome-extensions info "$ext" &>/dev/null; then
        log_info "Installing extension: $ext"
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions \
            org.gnome.Shell.Extensions InstallRemoteExtension s "$ext" 2>/dev/null || \
            log_warn "Failed to install $ext (install manually via Extension Manager)"
    fi
done

# Setup vicinae autostart
mkdir -p "$HOME/.config/autostart"
link_file "$ITERO_CONFIG/gnome/vicinae-autostart.desktop" "$HOME/.config/autostart/vicinae.desktop"

# Load dconf settings
local dconf_file="$ITERO_CONFIG/gnome/dconf.ini"
if [[ -f "$dconf_file" ]]; then
    if file_has_changed "$dconf_file" || should_update; then
        dconf load / < "$dconf_file"
        log_ok "Loaded GNOME dconf settings"
    fi
fi

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
local plymouth_tar="$ITERO_CONFIG/gnome/plymouth-theme.tar.xz"
local theme_name="dotLockG"
local theme_dest="/usr/share/plymouth/themes/$theme_name"

if [[ ! -d "$theme_dest" ]]; then
    sudo mkdir -p "$theme_dest"
    sudo tar -xJf "$plymouth_tar" -C "$theme_dest"

    sudo plymouth-set-default-theme "$theme_name" -R
    log_ok "Installed Plymouth theme: $theme_name"
fi

# Set user avatar
local avatar_src="$ITERO_CONFIG/gnome/avatar.jpg"
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

log_ok "GNOME setup complete"
