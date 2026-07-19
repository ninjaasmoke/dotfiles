#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
fake_home=$(mktemp -d)
trap 'rm -rf "$fake_home"' EXIT

output=$(HOME="$fake_home" "$root/install.sh" --dry-run)
grep -q 'Dry run complete.' <<< "$output"
test ! -e "$fake_home/.config/hypr"
test ! -e "$fake_home/.local/state/dotfiles/backups"

printf '%s\n' 'install dry-run test passed'
