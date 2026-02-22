#!/bin/bash

if is_linux; then
    log_info "Installing snapshot tools..."

    root_fstype="$(findmnt / -o FSTYPE -n 2>/dev/null)"
    if [[ "$root_fstype" != "btrfs" ]]; then
        log_warn "Root filesystem is $root_fstype, skipping btrfs snapshot setup"
        return 0
    fi

    # Core snapshot management
    dnf_install snapper libdnf5-plugin-actions

    # GUI for snapshot management
    dnf_install btrfs-assistant

    # Boot into snapshots from GRUB
    dnf_enable_copr_repo "kylegospo/grub-btrfs"
    dnf_install grub-btrfs

    # Configure snapper for root if not already configured
    if ! sudo snapper -c root get-config &>/dev/null; then
        sudo snapper -c root create-config /
        log_ok "Created snapper config for root"
    fi

    # Mount .snapshots subvolume via fstab so grub-btrfs can monitor it
    if ! grep -q '/.snapshots' /etc/fstab; then
        root_uuid=$(grep ' / ' /etc/fstab | grep btrfs | awk '{print $1}')
        echo "${root_uuid} /.snapshots btrfs subvol=root/.snapshots,compress=zstd:1 0 0" | sudo tee -a /etc/fstab > /dev/null
        sudo systemctl daemon-reload
        sudo mount /.snapshots
        log_ok "Added /.snapshots to fstab"
    fi

    # Set retention: keep latest 3 snapshots
    sudo snapper -c root set-config "NUMBER_LIMIT=3"

    # Disable timeline snapshots (dnf triggers are sufficient for desktops)
    sudo snapper -c root set-config "TIMELINE_CREATE=no"

    # Link dnf5 actions file for automatic pre/post snapshots on dnf transactions
    actions_dir="/etc/dnf/libdnf5-plugins/actions.d"
    sudo mkdir -p "$actions_dir"

    if [ ! -f "$actions_dir/snapper.actions" ]; then
        sudo cp "$ITERO_CONFIG/snapshots/snapper.actions" "$actions_dir/snapper.actions"
        log_ok "Installed dnf5 snapper actions file"
    fi

    # Enable systemd services
    sudo systemctl enable --now snapper-cleanup.timer
    sudo systemctl enable --now grub-btrfs.path

    # Regenerate GRUB config to pick up snapshot entries
    if [ -f /boot/grub2/grub.cfg ]; then
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null
    fi

    chmod +x "$ITERO_PATH/bin/itero-backup"
    install_desktop "$ITERO_CONFIG/snapshots/snapshots.desktop"
fi
