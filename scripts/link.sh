#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
mode=${1:---dry-run}
[[ "$mode" == --dry-run || "$mode" == --apply || "$mode" == --print-destination ]] || {
    printf 'usage: link.sh [--dry-run|--apply]\n' >&2
    exit 2
}

timestamp=$(date +%Y%m%d-%H%M%S)
backup_root="$HOME/.local/state/dotfiles/backups/$timestamp"

managed_files=()
while IFS= read -r -d '' file; do
    managed_files+=("$file")
done < <(find "$root/config" "$root/bin" -type f -print0 | sort -z)

destination_for() {
    local source=$1
    case "$source" in
        "$root/config/"*)
            printf '%s/%s\n' "$HOME/.config" "${source#"$root/config/"}"
            ;;
        "$root/bin/"*)
            printf '%s/.local/bin/%s\n' "$HOME" "${source#"$root/bin/"}"
            ;;
        *)
            printf 'unmanaged source: %s\n' "$source" >&2
            exit 1
            ;;
    esac
}

if [[ "$mode" == --print-destination ]]; then
    (($# == 2)) || {
        printf 'usage: link.sh --print-destination SOURCE\n' >&2
        exit 2
    }
    destination_for "$2"
    exit 0
fi

backup_path_for() {
    printf '%s/%s\n' "$backup_root" "${1#"$HOME/"}"
}

confirm() {
    local prompt=$1 answer
    if [[ ! -t 0 ]]; then
        printf 'non-interactive conflict: %s\n' "$prompt" >&2
        exit 1
    fi
    read -r -p "$prompt [y/N] " answer
    [[ "$answer" == [yY] ]]
}

for source in "${managed_files[@]}"; do
    destination=$(destination_for "$source")
    printf '%s -> %s\n' "$source" "$destination"
    [[ "$mode" == --apply ]] || continue

    mkdir -p "$(dirname "$destination")"
    if [[ -L "$destination" && "$(readlink -f "$destination")" == "$source" ]]; then
        continue
    fi
    if [[ -e "$destination" || -L "$destination" ]]; then
        backup=$(backup_path_for "$destination")
        confirm "Back up and replace $destination?" || exit 0
        mkdir -p "$(dirname "$backup")"
        mv "$destination" "$backup"
    fi
    ln -s "$source" "$destination"
done

local_override="$HOME/.config/hypr/local.conf"
if [[ ! -e "$local_override" ]]; then
    printf '%s -> %s\n' "$root/local/hypr/local.conf.example" "$local_override"
    if [[ "$mode" == --apply ]]; then
        mkdir -p "$(dirname "$local_override")"
        cp "$root/local/hypr/local.conf.example" "$local_override"
    fi
fi

if [[ "$mode" == --apply ]]; then
    mkdir -p "$backup_root"
    find "$backup_root" -type f -print0 | sort -z | xargs -0 -r sha256sum > "$backup_root/SHA256SUMS"
    printf '%s\n' "backup: $backup_root"
fi
