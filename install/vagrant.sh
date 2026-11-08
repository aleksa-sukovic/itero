if ! is_linux; then
    return 0
fi

dnf_install \
    vagrant \
    vagrant-libvirt \
    libvirt-daemon-kvm \
    libvirt-client \
    qemu-kvm || return 1

# Enable local libvirt sockets: https://libvirt.org/daemons.html
sudo systemctl enable --now \
    virtqemud.socket \
    virtqemud-ro.socket \
    virtnetworkd.socket \
    virtstoraged.socket \
    virtnodedevd.socket \
    virtnwfilterd.socket \
    virtsecretd.socket \
    virtinterfaced.socket || return 1

if ! id -nG "$USER" | tr " " "\n" | grep -qx "libvirt"; then
    sudo usermod -aG libvirt "$USER" || return 1
    log_info "Log out and back in for libvirt group membership to take effect"
fi
