if is_linux; then
    # Check if NVIDIA GPU is present
    if ! lspci | grep -qi nvidia; then
        return 0
    fi

    log_info "Installing NVIDIA proprietary drivers..."

    # RPM Fusion guide: https://rpmfusion.org/Howto/NVIDIA
    dnf_install akmod-nvidia xorg-x11-drv-nvidia-cuda
    log_warn "Reboot after NVIDIA installation to load the new driver"
fi
