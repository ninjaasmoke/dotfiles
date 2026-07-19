#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

for path in \
    README \
    install.sh \
    packages/core.txt \
    packages/desktop.txt \
    config/hypr/hyprland.conf \
    config/kitty/kitty.conf \
    config/zsh/.zshrc \
    config/waybar/config.jsonc \
    scripts/verify.sh; do
    test -e "$root/$path" || {
        printf 'missing: %s\n' "$path" >&2
        exit 1
    }
done

printf '%s\n' 'layout test passed'
