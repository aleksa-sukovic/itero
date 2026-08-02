if ! command_exists pi || should_update; then
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
fi

link_mirror "$ITERO_CONFIG/pi" "$HOME/.pi/agent"

if ! pi list 2>/dev/null | grep -Fq "@narumitw/pi-web-search"; then
    pi install npm:@narumitw/pi-web-search
elif should_update; then
    pi update npm:@narumitw/pi-web-search
fi
