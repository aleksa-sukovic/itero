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

    if lspci | grep -qi nvidia && ! command_exists nvidia-ctk; then
        log_info "Installing NVIDIA Container Toolkit..."

        sudo dnf config-manager addrepo -y \
            --from-repofile https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo

        dnf_install nvidia-container-toolkit

        sudo nvidia-ctk runtime configure --runtime=docker
        sudo systemctl restart docker
        log_ok "NVIDIA Container Toolkit installed and Docker runtime configured"
    fi
fi
