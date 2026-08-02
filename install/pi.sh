if ! command_exists pi || should_update; then
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
fi

link_mirror "$ITERO_CONFIG/pi" "$HOME/.pi/agent"

pi_extensions=(
    "pi-web-access"
)

for extension in "${pi_extensions[@]}"; do
    if ! pi list 2>/dev/null | grep -Fq "$extension"; then
        pi install "npm:$extension"
    elif should_update; then
        pi update "npm:$extension"
    fi
done
