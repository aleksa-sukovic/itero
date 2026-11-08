if is_linux; then
    dnf_install k9s
elif is_macos; then
    brew_install derailed/k9s/k9s
fi
