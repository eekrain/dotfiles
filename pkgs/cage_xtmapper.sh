#!/bin/bash
# cage_xtmapper.sh — our rewrite of upstream Xtr126/cage-xtmapper v0.2.0
#
# Launches cage (patched kiosk compositor) running `waydroid show-full-ui`,
# waits for Android boot, then starts XtMapper's RemoteServiceShell inside
# the container so it can inject host input events.
#
# Improvements over upstream:
# - doas-native (upstream uses sudo; this host uses doas — see default-settings.nix)
# - cleanup trap: stops the waydroid user session on exit, so the NEXT launch
#   isn't fighting a stale session from a previous crash
# - pre-launch systemd health check: if waydroid-container.service is in
#   'failed' state (typical after a hard cage crash), reset-failed + restart
#   it. Otherwise `doas waydroid container start` hangs forever talking to a
#   dead daemon.
# - boot wait has a 120s timeout instead of looping indefinitely
# - log lines prefixed [cage-xtmapper] on stderr for easy grep
# - deliberately NO `set -e`/`pipefail`: EGL/Mesa warnings inside the
#   container are non-fatal but return non-zero; `set -e` would force-close
#   the cage window on the first warning (regression we hit & fixed).

# NOTE: upstream deliberately does NOT use `set -e`/`-u`/`pipefail` here.
# The EGL/Mesa stack inside the waydroid container emits non-fatal warnings
# (e.g. "EGL-MAIN: failed to get driver name for fd -1") that return
# non-zero, and XtMapper keeps running fine regardless. `set -e` causes
# the script to bail on those warnings, force-closing the cage window.
# We keep nothing more aggressive than plain bash defaults.
set +e

# ---------------------------------------------------------------------------
# Argument parsing (preserved from upstream)
# ---------------------------------------------------------------------------
xtmapper_args=("--wayland-client")
use_adb=0

while [ $# -gt 0 ]; do
    case "$1" in
        --window-width)
            shift; export XTMAPPER_WIDTH="$1"
            ;;
        --window-height)
            shift; export XTMAPPER_HEIGHT="$1"
            ;;
        --refresh-mhz)
            shift; export XTMAPPER_REFRESH="$1"
            ;;
        --print-output-info)
            XTMAPPER_WIDTH=1 XTMAPPER_HEIGHT=1 XTMAPPER_PRINT_OUTPUT_INFO=1 \
                exec cage_xtmapper -- sleep 1
            ;;
        --window-no-title-bar)
            export WLR_NO_DECORATION=1
            ;;
        --adb)
            use_adb=1
            ;;
        --xtmapper-args)
            shift
            while [ $# -gt 0 ]; do
                xtmapper_args+=("$1")
                shift
            done
            ;;
        *)
            echo "[cage-xtmapper] invalid argument: $1" >&2
            exit 1
            ;;
    esac
    shift
done

# ---------------------------------------------------------------------------
# Steam gaming mode passthrough (preserved from upstream)
# ---------------------------------------------------------------------------
if [[ -n "${GAMESCOPE_WAYLAND_DISPLAY:-}" ]]; then
    unset DISPLAY
    export WAYLAND_DISPLAY="$GAMESCOPE_WAYLAND_DISPLAY"
fi

# ---------------------------------------------------------------------------
# Pre-launch systemd health check.
#
# After a hard cage crash, waydroid-container.service often ends up in
# 'failed' state (its main PID was killed). In that state, the daemon no
# longer registers on the system bus, and `doas waydroid container start`
# hangs forever trying to talk to it. Detect that case and recover.
# ---------------------------------------------------------------------------
if ! systemctl is-active --quiet waydroid-container.service 2>/dev/null; then
    echo "[cage-xtmapper] waydroid-container.service not active; resetting + restarting..." >&2
    doas systemctl reset-failed waydroid-container.service 2>/dev/null || true
    doas systemctl restart waydroid-container.service
    # Wait briefly for the daemon to register on D-Bus before proceeding.
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        if systemctl is-active --quiet waydroid-container.service; then
            break
        fi
        sleep 1
    done
fi

# ---------------------------------------------------------------------------
# Stop any stale user session from a previous run.
# (Matches upstream behavior; idempotent — no-op if no session is running.)
# ---------------------------------------------------------------------------
echo "[cage-xtmapper] stopping any stale waydroid user session..." >&2
waydroid session stop >&2 2>&1 || true

# ---------------------------------------------------------------------------
# Cleanup trap.
#
# When cage exits (user closes window, crash, Ctrl-C, SIGTERM), stop the
# waydroid user session so the NEXT launch starts clean. We deliberately do
# NOT touch waydroid-container.service here — that's systemd-managed and
# should survive across user session teardowns.
# ---------------------------------------------------------------------------
cleanup() {
    echo "[cage-xtmapper] cleaning up waydroid user session..." >&2
    waydroid session stop >&2 2>&1 || true
}
trap cleanup EXIT INT TERM

# ---------------------------------------------------------------------------
# Android BOOTCLASSPATH (preserved verbatim from upstream).
#
# Required by app_process when we exec RemoteServiceShell below — these are
# the framework JARs ART needs to bootstrap the Android runtime.
# ---------------------------------------------------------------------------
BOOTCLASSPATH='/apex/com.android.art/javalib/core-oj.jar:/apex/com.android.art/javalib/core-libart.jar:/apex/com.android.art/javalib/okhttp.jar:/apex/com.android.art/javalib/bouncycastle.jar:/apex/com.android.art/javalib/apache-xml.jar:/system/framework/framework.jar:/system/framework/framework-graphics.jar:/system/framework/ext.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/apex/com.android.i18n/javalib/core-icu4j.jar:/apex/com.android.adservices/javalib/framework-adservices.jar:/apex/com.android.adservices/javalib/framework-sdksandbox.jar:/apex/com.android.appsearch/javalib/framework-appsearch.jar:/apex/com.android.btservices/javalib/framework-bluetooth.jar:/apex/com.android.conscrypt/javalib/conscrypt.jar:/apex/com.android.ipsec/javalib/android.net.ipsec.ike.jar:/apex/com.android.media/javalib/updatable-media.jar:/apex/com.android.mediaprovider/javalib/framework-mediaprovider.jar:/apex/com.android.ondevicepersonalization/javalib/framework-ondevicepersonalization.jar:/apex/com.android.os.statsd/javalib/framework-statsd.jar:/apex/com.android.permission/javalib/framework-permission.jar:/apex/com.android.permission/javalib/framework-permission-s.jar:/apex/com.android.scheduling/javalib/framework-scheduling.jar:/apex/com.android.sdkext/javalib/framework-sdkextensions.jar:/apex/com.android.tethering/javalib/framework-connectivity.jar:/apex/com.android.tethering/javalib/framework-connectivity-t.jar:/apex/com.android.tethering/javalib/framework-tethering.jar:/apex/com.android.uwb/javalib/framework-uwb.jar:/apex/com.android.wifi/javalib/framework-wifi.jar'

# ---------------------------------------------------------------------------
# Ensure the container is running (idempotent — safe if already up).
# ---------------------------------------------------------------------------
echo "[cage-xtmapper] ensuring waydroid container is running..." >&2
doas waydroid container start >&2 2>&1 || true

# ---------------------------------------------------------------------------
# Find the XtMapper APK inside the container.
#
# Tries the debug build first, then release. Sets APK_PATH and
# NATIVE_LIB_PATH on success. Errors out on stderr if neither is installed.
# Args: $1 = full command prefix, e.g. "doas waydroid" or "adb".
# ---------------------------------------------------------------------------
find_xtmapper_apk() {
    local prefix="$1"
    local abi
    local pkg
    local candidate

    abi="$($prefix shell getprop ro.product.cpu.abi 2>/dev/null | tr -d '\r')"
    APK_PATH=""
    NATIVE_LIB_PATH=""
    for pkg in xtr.keymapper.debug xtr.keymapper; do
        candidate="$($prefix shell pm path "$pkg" 2>/dev/null | cut -d ':' -f 2 | tr -d '\r')"
        if [ -n "$candidate" ]; then
            APK_PATH="$candidate"
            NATIVE_LIB_PATH="$(dirname "$APK_PATH")/lib/$abi"
            echo "[cage-xtmapper] found XtMapper: $pkg at $APK_PATH (abi=$abi)" >&2
            return 0
        fi
    done
    echo "[cage-xtmapper] ERROR: no XtMapper installation found inside Waydroid." >&2
    echo "[cage-xtmapper] Install xtr.keymapper from https://github.com/Xtr126/XtMapper/releases" >&2
    return 1
}

# ---------------------------------------------------------------------------
# Launch path A (default): use `doas waydroid shell` to talk to the container.
# Cage wraps waydroid as a nested compositor; its patched build pipes host
# keyboard/mouse events to XtMapper via the --wayland-client protocol.
# ---------------------------------------------------------------------------
launch_via_waydroid() {
    cage_xtmapper waydroid show-full-ui | (
        # Wait for Android boot, but no longer than 120s.
        deadline=$(( $(date +%s) + 120 ))
        while [[ -z "$(doas waydroid shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" ]]; do
            if [ "$(date +%s)" -ge "$deadline" ]; then
                echo "[cage-xtmapper] timed out waiting for Android boot" >&2
                exit 1
            fi
            sleep 1
        done
        echo "[cage-xtmapper] Android boot completed" >&2

        # find_xtmapper_apk runs in this subshell; sets APK_PATH/NATIVE_LIB_PATH.
        find_xtmapper_apk "doas waydroid"

        # NOTE: the quoting on the sh -c argument is deliberately lifted
        # verbatim from upstream — bash concatenates the double-quoted,
        # single-quoted, and array-expansion pieces into one string that
        # /system/bin/sh inside the container evaluates. Don't "tidy" it.
        exec doas waydroid shell -- sh -c "exec env BOOTCLASSPATH=\$BOOTCLASSPATH:$BOOTCLASSPATH /system/bin/app_process \
            -Djava.library.path="$NATIVE_LIB_PATH" \
            -Djava.class.path="$APK_PATH" \
            / xtr.keymapper.server.RemoteServiceShell "'"$@"' _ ${xtmapper_args[@]}
    )
}

# ---------------------------------------------------------------------------
# Launch path B (--adb flag): use `adb shell` instead of `doas waydroid shell`.
# Useful when debugging the container directly via ADB.
# ---------------------------------------------------------------------------
launch_via_adb() {
    cage_xtmapper waydroid show-full-ui | (
        adb wait-for-device
        deadline=$(( $(date +%s) + 120 ))
        while [[ -z "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" ]]; do
            if [ "$(date +%s)" -ge "$deadline" ]; then
                echo "[cage-xtmapper] timed out waiting for Android boot" >&2
                exit 1
            fi
            sleep 1
        done

        find_xtmapper_apk adb

        CMD="/system/bin/app_process \\
            -Djava.library.path=\"$NATIVE_LIB_PATH\" \\
            -Djava.class.path=\"$APK_PATH\" \\
            / xtr.keymapper.server.RemoteServiceShell ${xtmapper_args[@]}"

        exec adb shell "$CMD"
    )
}

if [ "$use_adb" = 1 ]; then
    launch_via_adb
else
    launch_via_waydroid
fi
