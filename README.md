# ❄️ Nahom's Dotfiles (Arch Linux)

Welcome to my personal configuration files. Credit goes to JakooLit and Inir. This setup is built for a fast, keyboard-centric workflow on Wayland, blending aesthetics with performance.

## 🖥️ System Overview
* **OS:** Arch Linux
* **WM:** [Hyprland](https://hyprland.org/) & [Niri](https://github.com/YaLTeR/niri)
* **Shell:** [Fish](https://fishshell.com/) with [Starship](https://starship.rs/)
* **Terminal:** Kitty / Alacritty / Ghostty
* **UI Framework:** [Quickshell](https://quickshell.outfox.dev/) (Custom UI)
* **Bar:** Waybar / Quickshell
* **Launcher:** Rofi / Fuzzel
* **Theming:** Wallust (Dynamic Colors)

## ✨ Key Features
- **Hybrid UI:** Integrated Quickshell components for a modern, reactive interface.
- **Dynamic Theming:** Colors generated from wallpapers using `wallust`.
- **Dual WM Support:** Seamlessly switch between the tiling power of Hyprland and the scrolling layouts of Niri.
- **Optimized Shell:** Custom Fish aliases and a fast Starship prompt.

## 📸 Screenshots
> [!TIP]
> Add your screenshots here later by dragging images into this README on GitHub!

## 🛠️ Installation

### 1. Prerequisites
Ensure you have the following installed (via `pacman` or `yay`):
```bash
yay -S hyprland niri quickshell-git waybar kitty starship-bin fish wallust-git rofi-wayland
```
2. Clone the Repository
```bash
cd ~/.config
git clone [https://github.com/shebaww/Dot-Files-Arch-Linux-Hyprland.git](https://github.com/shebaww/Dot-Files-Arch-Linux-Hyprland.git) .
```
3. Apply Wallpapers
This setup uses swww for wallpapers. Run the following to initialize:

```bash
swww init
wallust run /path/to/your/wallpaper.jpg
```
⚠️ Notes
Personal Files: Sensitive data (Firebase keys, VPN configs, personal journals) has been excluded for security.

Paths: You may need to update wallpaper paths in hypr/hyprland.conf to match your directory structure.

Maintained by Nahom
Credit goes to JakooLit's Dot files and inir quickshell dotfiles, for refernce.
