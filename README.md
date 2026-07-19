# Minimal Hyprland

Clean, lightweight Hyprland configuration for Arch Linux.

## Features

- Dwindle tiling with focus on hover
- Super plus mouse drag to move and resize windows
- Pure black shell
- Square windows with small gaps
- Fast window animations
- Waybar with workspaces, clock, audio, battery, network, Bluetooth, and tray
- Rofi application launcher and clipboard history
- Dunst notifications
- Wlogout power menu
- Hyprlock and Hypridle
- Screenshot and clipboard helper scripts

## Repository layout

```text
config/hypr/                     -> ~/.config/hypr/
config/waybar/                   -> ~/.config/waybar/
config/rofi/                     -> ~/.config/rofi/
config/dunst/                    -> ~/.config/dunst/
config/wlogout/                  -> ~/.config/wlogout/
config/uwsm/                     -> ~/.config/uwsm/
share/hypr/                      -> ~/.local/share/hypr/
bin/                             -> ~/.local/bin/
```

## Restore

Back up the existing files first. Then copy the repository contents to the
matching paths:

```bash
cp -a config/hypr/*.conf ~/.config/hypr/
cp -a config/waybar/* ~/.config/waybar/
cp -a config/rofi/* ~/.config/rofi/
cp -a config/dunst/* ~/.config/dunst/
cp -a config/wlogout/* ~/.config/wlogout/
mkdir -p ~/.config/uwsm/env-hyprland.d ~/.local/share/hypr ~/.local/bin
cp -a config/uwsm/env-hyprland.d/* ~/.config/uwsm/env-hyprland.d/
cp -a share/hypr/* ~/.local/share/hypr/
cp -a bin/* ~/.local/bin/
chmod +x ~/.local/bin/minimal-*
hyprctl reload
```

## Shortcuts

| Shortcut | Action |
| --- | --- |
| Super plus T | Terminal |
| Super plus B | Default browser |
| Super plus E | Dolphin file manager |
| Super plus A | Rofi application launcher |
| Super plus Space | Rofi application launcher |
| Super plus V | Clipboard history |
| Super plus S | Toggle scratchpad |
| Super plus L | Lock |
| Ctrl plus Alt plus Delete | Power menu |
| Super plus Q | Close window |
| Super plus F | Fullscreen |
| Super plus Shift plus Space | Toggle floating |
| Super plus number | Switch workspace |
| Super plus Shift plus number | Move window to workspace |

## Dependencies

The active setup uses these installed packages:

```text
hyprland
waybar
rofi
dunst
wlogout
hyprlock
hypridle
kitty
dolphin
wl-clipboard
cliphist
grim
slurp
satty
network-manager-applet
blueman
```
