#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

log_ok()   { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}!${NC} $1"; }
log_info() { echo -e "${BLUE}→${NC} $1"; }

is_linux() { [[ "$(uname -s)" == "Linux" ]] }
is_mac() { [[ "$(uname -s)" == "Darwin" ]] }
command_exists() { command -v "$1" &>/dev/null; }
package_exists() { rpm -q "$1" &>/dev/null; }
should_update() { [[ "${ITERO_UPDATE:-false}" == true ]]; }
get_flavor() { echo "$1" | sed 's/^catppuccin-//'; }

# Read the system accent color from GNOME, defaulting to blue.
get_accent_color() {
    if command_exists gsettings; then
        local accent
        accent="$(gsettings get org.gnome.desktop.interface accent-color 2>/dev/null | tr -d "'")"
        echo "${accent:-blue}"
    else
        echo "blue"
    fi
}

# Map a GNOME accent color to the corresponding palette color name.
map_accent_to_palette() {
    case "$1" in
        orange) echo "peach" ;;
        purple) echo "mauve" ;;
        slate)  echo "lavender" ;;
        *)      echo "$1" ;;
    esac
}

ITERO_FAILED_INSTALLS=()

# Check if a component should be installed based on ITERO_COMPONENTS env var.
should_install() {
    local name="$1"
    local filter="${ITERO_COMPONENTS:-all}"

    [[ "$filter" == "all" ]] && return 0

    IFS=',' read -ra components <<< "$filter"
    for component in "${components[@]}"; do
        [[ "$component" == "$name" ]] && return 0
    done

    return 1
}

# Run an install script with error handling. Failures are logged but don't stop the process.
run_install() {
    local script="$1"
    local name
    name="$(basename "$script" .sh)"

    if ! should_install "$name"; then
        return 0
    fi

    if (source "$ITERO_PATH/lib/helpers.sh" && source "$script"); then
        return 0
    else
        log_warn "Failed to install: $name"
        ITERO_FAILED_INSTALLS+=("$name")
        return 0
    fi
}

# Print a summary of failed installations, if any.
print_install_summary() {
    if [ ${#ITERO_FAILED_INSTALLS[@]} -eq 0 ]; then
        return 0
    fi

    echo ""
    log_warn "The following components failed to install:"
    for name in "${ITERO_FAILED_INSTALLS[@]}"; do
        echo "  - $name"
    done
    echo ""
    log_info "Re-run itero to retry, or install individually with: ITERO_COMPONENTS=<name> itero"
}

# Install a .desktop file to the user's applications directory.
install_desktop() {
    local src="$1"
    local dest="$HOME/.local/share/applications/$(basename "$src")"

    mkdir -p "$HOME/.local/share/applications"
    cp "$src" "$dest"
    chmod +x "$dest"

    # update desktop database if available
    command_exists update-desktop-database && \
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null

    log_ok "Installed desktop file: $(basename "$src")"
}

# Create a symlink. Idempotent, handles conflicts, creates parent dirs.
link_file() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        return 0
    fi

    [ -L "$dest" ] && rm "$dest"

    if [ -e "$dest" ]; then
        log_warn "Exists (not a symlink): $dest"
        return 1
    fi

    ln -s "$src" "$dest"
    log_ok "Linked: $dest"
}

# Exact-mirror a directory: symlink all files, remove stale links.
link_mirror() {
    local src="$1" dest="$2"
    mkdir -p "$dest"

    while IFS= read -r -d '' file; do
        local rel="${file#$src/}"
        link_file "$file" "$dest/$rel"
    done < <(find "$src" -type f -print0)

    while IFS= read -r -d '' link; do
        if [[ "$(readlink "$link")" == "$ITERO_PATH"* ]] && [ ! -e "$link" ]; then
            rm "$link"
            log_warn "Removed stale: $link"
        fi
    done < <(find "$dest" -type l -print0 2>/dev/null)
}

# Create a file from example, only if target doesn't exist.
# Converts existing symlinks to real files.
init_local() {
    local example="$1" target="$2"

    if [ -L "$target" ]; then
        if [ -f "$target" ]; then
            cp -L "$target" "$target.tmp" && rm "$target" && mv "$target.tmp" "$target"
        else
            rm "$target"
        fi
    fi

    [ -f "$target" ] && return 0

    mkdir -p "$(dirname "$target")"
    cp "$example" "$target"
    log_ok "Created: $target"
}

# Resolve a hex color value from a palette file.
resolve_palette_color() {
    local palette_file="$1"
    local color_name="$2"

    grep -oP "^${color_name}[[:space:]]*=[[:space:]]*\"#\\K[a-fA-F0-9]{6}" "$palette_file"
}

# Resolve accent hex color from a theme palette file.
resolve_accent_hex() {
    local palette_file="$1"
    local accent_name="$2"

    resolve_palette_color "$palette_file" "$accent_name"
}

# Convert a 6-digit hex color to an RGB tuple.
hex_to_rgb() {
    local hex="$1"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "${r}, ${g}, ${b}"
}

# Compile theme-specific templates from a canonical palette file.
compile_theme_templates() {
    local theme_dir="$1"
    local accent_name="$2"
    local config_dir="${3:-}"
    local palette_file="$theme_dir/palette.toml"

    [[ -f "$palette_file" ]] || { echo "No palette file: $palette_file" >&2; return 1; }
    local accent_hex
    accent_hex="$(resolve_accent_hex "$palette_file" "$accent_name")"
    [[ -n "$accent_hex" ]] || { echo "No accent '${accent_name}' in $palette_file" >&2; return 1; }
    local accent_rgb
    accent_rgb="$(hex_to_rgb "$accent_hex")"
    local accent_name_capitalized="$(echo "${accent_name:0:1}" | tr '[:lower:]' '[:upper:]')${accent_name:1}"

    local vars_file
    vars_file="$(mktemp)"
    grep -vE '^[[:space:]]*accent[[:space:]]*=' "$palette_file" > "$vars_file"
    {
        echo "accent = \"#${accent_hex}\""
        echo "accent_name = \"$accent_name\""
        echo "accent_rgb = \"$accent_rgb\""
        echo "accent_name_capitalized = \"$accent_name_capitalized\""
    } >> "$vars_file"

    compile_templates "$vars_file" "$theme_dir"
    [[ -n "$config_dir" ]] && compile_templates "$vars_file" "$config_dir"
    rm -f "$vars_file"
}

# Compile .tpl templates by substituting {{ key }} from a variables file and {{ $VAR }} from shell env.
compile_templates() {
    local variables_file="$1"
    local search_dir="$2"

    if [[ ! -f "$variables_file" ]]; then
        echo "No variables file: $variables_file" >&2
        return 1
    fi

    # Build sed expression from key = "value" pairs
    local sed_expr=""
    while IFS='=' read -r key value; do
        key=$(echo "$key" | xargs)
        [[ -z "$key" || "$key" == \#* ]] && continue

        value=$(echo "$value" | xargs)
        value="${value//\"/}"

        local value_nohash="${value#\#}"

        sed_expr+="s|{{ ${key} }}|${value}|g;"
        sed_expr+="s|{{ ${key}:nohash }}|${value_nohash}|g;"
    done < "$variables_file"

    local shell_var_pattern='{{ \$[A-Za-z_][A-Za-z_0-9]* }}'
    local strip_pattern='s/{{ \$//;s/ }}//'

    # Process each .tpl.* file by stripping .tpl from filename for output
    while IFS= read -r -d '' tpl; do
        local output="${tpl/.tpl/}"
        sed "$sed_expr" "$tpl" > "$output"

        # Expand {{ $VAR }} placeholders with shell variable values
        local shell_sed=""
        while IFS= read -r var; do
            [[ -z "$var" ]] && continue
            local val="${!var}"
            [[ -n "$val" ]] && shell_sed+="s|{{ \$$var }}|${val}|g;"
        done < <(grep -o "$shell_var_pattern" "$output" 2>/dev/null \
                 | sed "$strip_pattern" | sort -u)
        [[ -n "$shell_sed" ]] && sed -i "$shell_sed" "$output" || true
    done < <(find "$search_dir" -name '*.tpl.*' -print0)
}

# Enable a COPR repo, if not already enabled.
dnf_enable_copr_repo() {
    local repo="$1"

    if ! is_linux; then
        return 0
    fi

    if ! command_exists dnf; then
        log_warn "dnf not available, skipping repo enable"
        return 1
    fi

    # Convert owner/repo to owner:repo for matching
    local repo_search="${repo//\//:}"

    if ! dnf repolist --enabled 2>/dev/null | grep -q "copr.fedorainfracloud.org:${repo_search}"; then
        sudo dnf copr enable -y "$repo"
        log_ok "Enabled $repo repository"
    fi
}

# Install package(s) via dnf with optional additional arguments, if not already installed.
dnf_install() {
    if ! is_linux; then
        return 0
    fi

    if ! command_exists dnf; then
        log_warn "dnf not available, skipping install"
        return 1
    fi

    # If forcing update, install all packages
    if should_update; then
        sudo dnf install -y -q "$@"
        return $?
    fi

    # Filter out already-installed packages
    local to_install=()
    for pkg in "$@"; do
        if ! package_exists "$pkg"; then
            to_install+=("$pkg")
        fi
    done

    # Install only missing packages
    if [ ${#to_install[@]} -gt 0 ]; then
        sudo dnf install -y -q "${to_install[@]}"
    fi
}

# Install package via flatpak if not already installed.
flatpak_install() {
    local remote="flathub"
    local package="$1"

    if [[ $# -eq 2 ]]; then
        remote="$1"
        package="$2"
    fi

    if ! is_linux; then
        return 0
    fi

    if ! command_exists flatpak; then
        log_warn "flatpak not available, skipping install of $package"
        return 1
    fi

    if flatpak list --app | grep -q "$package"; then
        return 0
    fi

    flatpak install -y "$remote" "$package"
}

# Check if a file has changed based on its hash and saves the new hash if it has.
file_has_changed() {
    local file_path="$1"
    local update_hash="${2:-true}"

    [ ! -f "$file_path" ] && return 1

    local file_name="$(basename "$file_path")"
    local hash_file="$ITERO_STATE/${file_name}.hash"
    local current_hash="$(sha256sum "$file_path" | cut -d' ' -f1)"
    local stored_hash=""

    [ -f "$hash_file" ] && stored_hash="$(cat "$hash_file")"

    if [ "$current_hash" != "$stored_hash" ]; then
        [ "$update_hash" = true ] && echo "$current_hash" > "$hash_file"
        return 0
    fi

    return 1
}

# Set a configuration key=value pair in a file.
set_config_value() {
    local file="$1"
    local key="$2"
    local value="$3"

    sudo sed -i "s|^${key}=.*|${key}=${value}|" "$file"
}

# Allow the current user to write to a root-owned file via passwordless sudo tee.
allow_user_write() {
    local file="$1"
    local rule_name="$2"

    echo "$USER ALL=(root) NOPASSWD: /usr/bin/tee $file" \
        | sudo tee "/etc/sudoers.d/$rule_name" >/dev/null
    sudo chmod 440 "/etc/sudoers.d/$rule_name"
}
