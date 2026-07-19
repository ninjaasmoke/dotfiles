#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

usage() {
    printf '%s\n' \
        'usage: packages.sh list GROUP...' \
        '       packages.sh missing GROUP...' \
        '       packages.sh command GROUP...'
}

group_file() {
    case "$1" in
        core|desktop)
            printf '%s/%s.txt\n' "$root/packages" "$1"
            ;;
        optional/*)
            printf '%s/%s.txt\n' "$root/packages" "$1"
            ;;
        *)
            printf 'unknown package group: %s\n' "$1" >&2
            exit 2
            ;;
    esac
}

read_groups() {
    local group line
    for group in "$@"; do
        while IFS= read -r line; do
            [[ -z "$line" || "$line" == \#* ]] && continue
            printf '%s\n' "$line"
        done < "$(group_file "$group")"
    done | awk '!seen[$0]++'
}

case "${1:-}" in
    list)
        shift
        (($#)) || { usage >&2; exit 2; }
        read_groups "$@"
        ;;
    missing)
        shift
        (($#)) || { usage >&2; exit 2; }
        while IFS= read -r package; do
            pacman -Qq "$package" >/dev/null 2>&1 || printf '%s\n' "$package"
        done < <(read_groups "$@")
        ;;
    command)
        shift
        (($#)) || { usage >&2; exit 2; }
        mapfile -t packages < <(read_groups "$@")
        ((${#packages[@]})) || exit 0
        printf 'sudo pacman -S --needed'
        printf ' %q' "${packages[@]}"
        printf '\n'
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
