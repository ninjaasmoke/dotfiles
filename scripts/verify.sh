#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
mode=${1:-repository}

fail() {
    printf 'verification failed: %s\n' "$*" >&2
    exit 1
}

verify_repository() {
    local file
    for file in \
        README \
        install.sh \
        packages/core.txt \
        packages/desktop.txt \
        config/hypr/hyprland.conf \
        config/kitty/kitty.conf \
        config/zsh/.zshrc \
        config/waybar/config.jsonc \
        scripts/install.sh \
        scripts/link.sh \
        scripts/packages.sh \
        scripts/restore.sh \
        scripts/verify.sh; do
        test -e "$root/$file" || fail "missing $file"
    done

    while IFS= read -r -d '' file; do
        bash -n "$file"
    done < <(find "$root/bin" "$root/scripts" -type f -print0)

    jq -e . "$root/config/waybar/config.jsonc" >/dev/null
    rofi -config "$root/config/rofi/config.rasi" -dump-config >/dev/null

    while IFS= read -r -d '' file; do
        test -x "$file" || fail "not executable: $file"
    done < <(find "$root/bin" -type f -print0)

    if grep -RInE '/home/[A-Za-z0-9_.-]+|/run/user/[0-9]+' \
        "$root/config" "$root/bin" "$root/scripts"; then
        fail 'machine-specific absolute path found'
    fi
    if grep -RInP '\x{2014}|\x{2013}|\x{2212}' \
        "$root/config" "$root/bin" "$root/scripts"; then
        fail 'forbidden Unicode dash found'
    fi
    if grep -RIniE 'hyde|wallbash' "$root/config" "$root/bin"; then
        fail 'legacy framework or secret reference found'
    fi
    if grep -RInE '(^|[[:space:]])(api[_-]?key|secret|token)[[:space:]]*=' \
        "$root/config" "$root/bin"; then
        fail 'possible secret reference found'
    fi

    temp_home=$(mktemp -d)
    trap 'rm -rf "$temp_home"' RETURN
    mkdir -p "$temp_home/.config/hypr"
    cp "$root/local/hypr/local.conf.example" "$temp_home/.config/hypr/local.conf"
    validation=$(mktemp "$root/config/hypr/.verify.XXXXXX.conf")
    trap 'rm -f "$validation"; rm -rf "$temp_home"' RETURN
    sed '\|source = ./startup.conf|d' \
        "$root/config/hypr/hyprland.conf" > "$validation"
    HOME="$temp_home" XDG_CONFIG_HOME="$temp_home/.config" \
        Hyprland --verify-config -c "$validation" 2>&1 | grep -q 'config ok' ||
        fail 'Hyprland rejected repository configuration'
}

verify_deployed() {
    local source destination
    while IFS= read -r -d '' source; do
        destination=$("$root/scripts/link.sh" --print-destination "$source")
        test -L "$destination" || fail "not a symlink: $destination"
        test "$(readlink -f "$destination")" = "$source" ||
            fail "wrong symlink target: $destination"
    done < <(find "$root/config" "$root/bin" -type f -print0)
    test -f "$HOME/.config/hypr/local.conf" ||
        fail 'missing local Hyprland override'
    if command -v hyprctl >/dev/null 2>&1; then
        test -z "$(hyprctl configerrors)" || fail 'Hyprland has config errors'
    fi
}

case "$mode" in
    repository) verify_repository ;;
    deployed) verify_deployed ;;
    *) fail "usage: verify.sh repository|deployed" ;;
esac

printf '%s\n' "verification passed: $mode"
