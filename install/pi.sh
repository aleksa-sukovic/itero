if ! command_exists pi || should_update; then
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
fi
