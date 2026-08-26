if ! is_linux; then
    return 0
fi

log_info "Installing GitHub CLI..."

# Add GitHub's official signed repository
local github_repo_file="/etc/yum.repos.d/gh-cli.repo"
local github_repo_url="https://cli.github.com/packages/rpm/gh-cli.repo"

if [ ! -f "$github_repo_file" ]; then
    if ! sudo dnf config-manager addrepo --from-repofile="$github_repo_url"; then
        log_warn "Failed to add the GitHub CLI repository"
        return 1
    fi
    log_ok "Added the GitHub CLI repository"
fi

if ! dnf_install gh; then
    log_warn "Failed to install GitHub CLI"
    return 1
fi

log_ok "GitHub CLI ready"
