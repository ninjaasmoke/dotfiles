# minimal hyprland dotfiles

This repository mirrors the active lightweight Hyprland setup:

- direct Hyprland configuration with dwindle tiling and hover focus
- Waybar, Rofi, Dunst, and wlogout
- Wi-Fi and Bluetooth tray applets
- clipboard and screenshot helpers
- pure-black shell with square tiles

The repository layout mirrors the destination paths:

| Repository path | Destination |
| --- | --- |
| `config/hypr/` | `~/.config/hypr/` |
| `config/waybar/` | `~/.config/waybar/` |
| `config/rofi/` | `~/.config/rofi/` |
| `config/dunst/` | `~/.config/dunst/` |
| `config/wlogout/` | `~/.config/wlogout/` |
| `config/uwsm/` | `~/.config/uwsm/` |
| `share/hypr/` | `~/.local/share/hypr/` |
| `bin/` | `~/.local/bin/` |

These files are user-specific and intentionally exclude Hyde backups, generated
theme files, caches, and icons supplied by system packages.
