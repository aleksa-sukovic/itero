if is_linux; then
    if ! command_exists code; then
        # N.B. See official instructions: https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions
        log_info "Installing VS Code..."

        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

        dnf check-update
        dnf_install code

        log_ok "VS Code installed"
    fi
fi
