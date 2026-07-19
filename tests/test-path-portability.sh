#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
scan_paths=()
for path in "$root/config" "$root/bin" "$root/scripts"; do
    [ -e "$path" ] && scan_paths+=("$path")
done

if ((${#scan_paths[@]})) && grep -RInE '/home/[A-Za-z0-9_.-]+|/run/user/[0-9]+' \
    "${scan_paths[@]}"; then
    printf '%s\n' 'machine-specific absolute path found' >&2
    exit 1
fi

if ((${#scan_paths[@]})) && grep -RInP '\x{2014}|\x{2013}|\x{2212}' \
    "${scan_paths[@]}"; then
    printf '%s\n' 'forbidden Unicode dash found' >&2
    exit 1
fi

printf '%s\n' 'path portability test passed'
