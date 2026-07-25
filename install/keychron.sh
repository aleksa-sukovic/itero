if ! is_linux; then
    return 0
fi

log_info "Configuring Keychron WebHID access..."

if sudo install -Dm644 \
    "$ITERO_CONFIG/keychron/70-keychron-webhid.rules" \
    "/etc/udev/rules.d/70-keychron-webhid.rules" \
    && sudo udevadm control --reload-rules \
    && sudo udevadm trigger --subsystem-match="hidraw" --action="change"; then
    install_desktop "$ITERO_CONFIG/keychron/keychron-launcher.desktop"
    log_ok "Configured Keychron WebHID access"
else
    log_warn "Failed to configure Keychron WebHID access"
    return 1
fi
