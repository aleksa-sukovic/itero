#!/bin/bash

if is_linux; then
    log_info "Installing common dependencies..."

    # Remove unwanted repositories
    sudo rm -rf /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo
    sudo rm -rf /etc/yum.repos.d/google-chrome.repo

    # Update system
    sudo dnf makecache -q
    sudo dnf upgrade -y

    # Install packages
    dnf_install \
        zsh \
        zoxide \
        ripgrep \
        fd-find \
        fzf \
        jq \
        yq \

    dnf_install \
        wl-clipboard \
        ffmpeg-free \
        p7zip \
        poppler-utils \
        ImageMagick \

    # Enable RMP Fusion. See also: https://docs.fedoraproject.org/en-US/quick-docs/rpmfusion-setup/.
    fedora_release="$(rpm -E %fedora)"
    if ! package_exists rpmfusion-free-release || ! package_exists rpmfusion-nonfree-release; then
        sudo dnf install -y -q \
            "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_release}.noarch.rpm" \
            "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_release}.noarch.rpm"
        log_ok "Enabled RPM Fusion free and nonfree repositories"
    fi

    # Install and configure kernel headers and automatic driver builders
    dnf_install akmods kernel-devel linux-firmware
    sudo systemctl enable akmods

    # Configure system locale
    sudo localectl set-locale LANG="${SYSTEM_LOCALE:-en_US.UTF-8}"
    log_ok "Locale set to ${SYSTEM_LOCALE:-en_US.UTF-8}"

    # Configure timezone
    sudo timedatectl set-timezone "${SYSTEM_TIMEZONE:-Europe/Berlin}"
    log_ok "Timezone set to ${SYSTEM_TIMEZONE:-Europe/Berlin}"

    # Configure keyboard layouts
    sudo localectl set-x11-keymap "${KEYBOARD_LAYOUT:-us,de,rs}" "${KEYBOARD_MODEL:-pc105}"
    log_ok "Keyboard layouts set to ${KEYBOARD_LAYOUT:-us,de,rs}"

    # Configure hostname
    if [ -n "$HOST" ] && [ "$(hostname)" != "$HOST" ]; then
        sudo hostnamectl set-hostname "$HOST"
        sudo hostnamectl set-hostname --pretty "$HOST"
        log_ok "Hostname set to $HOST"
    fi

    # Configure git
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL"

    # Create common directories
    mkdir -p ~/Desktop ~/Downloads ~/Pictures ~/Pictures/Screenshots ~/Documents ~/Development
fi
