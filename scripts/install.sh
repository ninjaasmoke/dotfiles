#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then
    dry_run=true
    shift
fi
(($# == 0)) || {
    printf 'usage: install.sh [--dry-run]\n' >&2
    exit 2
}

[[ -x "$root/scripts/packages.sh" ]] || chmod +x "$root/scripts/packages.sh"

if [[ ! -r /etc/arch-release ]] || ! command -v pacman >/dev/null 2>&1; then
    printf '%s\n' 'This installer currently supports Arch Linux and Arch-based systems.' >&2
    exit 1
fi

groups=(core desktop)
optional=(optional/bluetooth optional/clipboard optional/power optional/screenshots)

printf '%s\n' 'Required package groups: core desktop'
printf '%s\n' 'Optional package groups:'
for group in "${optional[@]}"; do
    printf '  %s\n' "$group"
done

if [[ -t 0 && "$dry_run" == false ]]; then
    for group in "${optional[@]}"; do
        read -r -p "Install $group? [y/N] " answer
        [[ "$answer" == [yY] ]] && groups+=("$group")
    done
fi

printf '%s\n' 'Selected groups:'
printf '  %s\n' "${groups[@]}"

mapfile -t missing < <("$root/scripts/packages.sh" missing "${groups[@]}")
if ((${#missing[@]})); then
    printf '%s\n' 'Missing packages:'
    printf '  %s\n' "${missing[@]}"
    printf '%s\n' 'Install command:'
    "$root/scripts/packages.sh" command "${groups[@]}"
    if [[ "$dry_run" == true ]]; then
        printf '%s\n' 'Dry run: package installation skipped.'
    elif [[ -t 0 ]]; then
        read -r -p 'Run this package installation command? [y/N] ' answer
        if [[ "$answer" == [yY] ]]; then
            sudo pacman -S --needed "${missing[@]}"
        else
            printf '%s\n' 'Package installation declined.'
            exit 0
        fi
    else
        printf '%s\n' 'Non-interactive mode: package installation skipped.'
    fi
else
    printf '%s\n' 'All selected packages are installed.'
fi

if [[ "$dry_run" == true ]]; then
    printf '%s\n' 'Dry run complete.'
    exit 0
fi

[[ -x "$root/scripts/verify.sh" ]] || chmod +x "$root/scripts/verify.sh"
"$root/scripts/verify.sh" repository
"$root/scripts/link.sh" --apply
"$root/scripts/verify.sh" deployed

if command -v hyprctl >/dev/null 2>&1 && hyprctl instances >/dev/null 2>&1; then
    hyprctl reload config-only
fi
