#!/bin/bash

if ! is_linux; then
    return
fi

if package_exists chatgpt; then
    if should_update; then
        log_info "Updating ChatGPT..."
        if ! sudo dnf upgrade --refresh -y -q chatgpt; then
            log_warn "Failed to update ChatGPT"
            return 1
        fi
    fi
    return
fi

log_info "Installing ChatGPT..."

chatgpt_url="https://persistent.oaistatic.com/codex-app-prod/linux/rpm/latest/chatgpt.x86_64.rpm"
if ! sudo dnf install -y -q "$chatgpt_url"; then
    log_warn "Failed to install ChatGPT"
    return 1
fi

log_ok "ChatGPT installed"
