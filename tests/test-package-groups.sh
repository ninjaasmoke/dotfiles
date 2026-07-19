#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

for file in \
    packages/core.txt \
    packages/desktop.txt \
    packages/optional/bluetooth.txt \
    packages/optional/clipboard.txt \
    packages/optional/power.txt \
    packages/optional/screenshots.txt; do
    test -s "$root/$file" || {
        printf 'empty package group: %s\n' "$file" >&2
        exit 1
    }
    awk '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        $0 !~ /^[a-zA-Z0-9@._+:-]+$/ { exit 1 }
    ' "$root/$file" || {
        printf 'invalid package name in: %s\n' "$file" >&2
        exit 1
    }
done

printf '%s\n' 'package group test passed'
