if is_linux; then
    if ! command_exists gitkraken || should_update; then
        log_info "Installing GitKraken..."

        # Extract the actual RPM download URL from the download page
        RPM_URL=$(curl -fsSL https://www.gitkraken.com/download/linux-rpm | grep -o 'https://[^"]*\.rpm' | head -1)

        if [ -z "$RPM_URL" ]; then
            log_warn "Failed to find GitKraken download URL"
            return 1
        fi

        # Download the RPM to a temporary file and install it
        TMP_RPM=$(mktemp --suffix=.rpm)

        if curl -fsSL -o "$TMP_RPM" "$RPM_URL"; then
            sudo dnf install -y "$TMP_RPM" &>/dev/null
            rm -f "$TMP_RPM"
            log_ok "GitKraken installed"
        else
            rm -f "$TMP_RPM"
            log_warn "Failed to download GitKraken"
            return 1
        fi
    fi
fi
