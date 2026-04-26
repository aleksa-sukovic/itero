# Bluetooth audio configuration for WirePlumber.
#
# Codec ordering: aptX Adaptive > aptX HD > LDAC > aptX > SBC-XQ > AAC > SBC. AAC is demoted because
# its transport acquisition fails on certain devices, causing AVDTP stream errors.

if is_linux; then
    link_file "$ITERO_CONFIG/bluetooth/51-bluetooth-codecs.conf" \
        "$HOME/.config/wireplumber/wireplumber.conf.d/51-bluetooth-codecs.conf"

    # N.B. Clear any hardcoded default sink so priority-based selection takes over
    wpctl clear-default 0
fi
