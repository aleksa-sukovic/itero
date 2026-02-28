#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

# N.B. ffmpeg-free conflicts with the RPM Fusion ffmpeg package and must be removed first.
if package_exists ffmpeg-free; then
    sudo dnf remove -y -q ffmpeg-free \
        libswscale-free \
        libswresample-free \
        libavcodec-free \
        libavformat-free \
        libavutil-free \
        libpostproc-free \
        libavdevice-free \
        libavfilter-free
    log_ok "Removed ffmpeg-free"
fi
