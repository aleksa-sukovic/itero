# Bluetooth audio configuration for WirePlumber.
#
# Codec ordering: LDAC > SBC-XQ > SBC > AAC. AAC is demoted because its
# transport acquisition fails on certain devices (e.g., Sony WF-1000XM6),
# causing AVDTP stream errors.

if is_linux; then
    link_file "$ITERO_CONFIG/bluetooth/51-bluetooth-codecs.conf" \
        "$HOME/.config/wireplumber/wireplumber.conf.d/51-bluetooth-codecs.conf"

    # N.B. Clear any hardcoded default sink so priority-based selection takes over
    wpctl clear-default 0
fi
