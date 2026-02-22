if is_linux; then
    if ! command_exists docker; then
        log_info "Installing Docker..."

        sudo dnf config-manager addrepo -y \
            --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo

        dnf_install \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin \
            docker-compose-plugin

        sudo systemctl enable --now docker

        getent group docker > /dev/null || sudo groupadd docker
        sudo usermod -aG docker $USER
        log_info "Log out and back in for Docker group membership to take effect"
    fi
fi
