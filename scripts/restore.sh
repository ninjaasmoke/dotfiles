#!/usr/bin/env bash
set -euo pipefail

backup=${1:-}
[[ -n "$backup" && -d "$backup" && -f "$backup/SHA256SUMS" ]] || {
    printf 'usage: restore.sh BACKUP_DIR\n' >&2
    exit 2
}

sha256sum -c "$backup/SHA256SUMS" >/dev/null
mapfile -t files < <(find "$backup" -type f ! -name SHA256SUMS \
    ! -path "$backup/restore-current/*" -printf '%P\n' | sort)

printf '%s\n' 'Files to restore:'
printf '  %s\n' "${files[@]}"
if [[ ! -t 0 ]]; then
    printf '%s\n' 'Restore requires an interactive confirmation.' >&2
    exit 1
fi
read -r -p 'Restore these files? [y/N] ' answer
[[ "$answer" == [yY] ]] || exit 0

mkdir -p "$backup/restore-current"
for relative in "${files[@]}"; do
    source="$backup/$relative"
    destination="$HOME/$relative"
    if [[ -e "$destination" || -L "$destination" ]]; then
        current="$backup/restore-current/$relative"
        mkdir -p "$(dirname "$current")"
        mv "$destination" "$current"
    fi
    mkdir -p "$(dirname "$destination")"
    cp -a "$source" "$destination"
done

sha256sum -c "$backup/SHA256SUMS" >/dev/null
printf '%s\n' 'restore complete'
