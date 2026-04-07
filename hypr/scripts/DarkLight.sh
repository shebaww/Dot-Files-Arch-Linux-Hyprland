#!/bin/bash
## /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Dark / Light mode toggle — enhanced version
# Improvements: error handling, deduped logic, safe qt paths, validated wallpaper,
#               initialized cache, consistent kill strategy, removed dead code.

set -euo pipefail

# ── Paths ────────────────────────────────────────────────────────────────────
wallpaper_base_path="$HOME/Pictures/wallpapers/Dynamic-Wallpapers"
dark_wallpapers="$wallpaper_base_path/Dark"
light_wallpapers="$wallpaper_base_path/Light"
hypr_config_path="$HOME/.config/hypr"
swaync_style="$HOME/.config/swaync/style.css"
ags_style="$HOME/.config/ags/user/style.css"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
notif="$HOME/.config/swaync/images/bell.png"
wallust_rofi="$HOME/.config/wallust/templates/colors-rofi.rasi"
wallust_config="$HOME/.config/wallust/wallust.toml"
theme_cache="$HOME/.cache/.theme_mode"

pallete_dark="dark16"
pallete_light="light16"

# ── Helpers ───────────────────────────────────────────────────────────────────
log()  { echo "[theme-toggle] $*"; }
warn() { echo "[theme-toggle] WARNING: $*" >&2; }

die() {
    echo "[theme-toggle] ERROR: $*" >&2
    exit 1
}

# Run a command and warn (but don't abort) on failure
try() {
    "$@" || warn "Command failed (non-fatal): $*"
}

notify_user() {
    try notify-send -u low -i "$notif" " Switching to" " $1 mode"
}

# ── Determine current → next mode ─────────────────────────────────────────────
# Initialise cache to "Dark" on first run so first toggle goes to Light
if [ ! -f "$theme_cache" ]; then
    echo "Dark" > "$theme_cache"
fi

current_mode="$(cat "$theme_cache")"
if [ "$current_mode" = "Light" ]; then
    next_mode="Dark"
    wallpaper_dir="$dark_wallpapers"
else
    next_mode="Light"
    wallpaper_dir="$light_wallpapers"
fi

log "Switching from $current_mode → $next_mode"

# ── Write mode immediately so a crash mid-script doesn't leave stale state ───
echo "$next_mode" > "$theme_cache"

# ── Notify early so the user sees feedback right away ────────────────────────
notify_user "$next_mode"

# ── Kill compositor-aware processes (SIGUSR1 for soft reload where supported) ─
for proc in waybar swaync ags; do
    # SIGUSR1 is meaningful for these; ignore errors if not running
    killall -SIGUSR1 "$proc" 2>/dev/null || true
done

# ── Initialise swww ───────────────────────────────────────────────────────────
if ! swww query &>/dev/null; then
    swww-daemon --format xrgb &
    sleep 1   # give the daemon a moment to be ready
fi

# ── wallust palette ───────────────────────────────────────────────────────────
if [ -f "$wallust_config" ]; then
    palette_value="${next_mode,,}16"   # dark16 / light16 — bash lowercase expansion
    try sed -i "s/^palette = .*/palette = \"$palette_value\"/" "$wallust_config"
else
    warn "wallust config not found: $wallust_config"
fi

# ── Waybar style ──────────────────────────────────────────────────────────────
set_waybar_style() {
    local theme="$1"
    local waybar_styles="$HOME/.config/waybar/style"
    local waybar_style_link="$HOME/.config/waybar/style.css"
    # Filename must contain [Dark] or [Light] (case-insensitive)
    local style_file
    style_file=$(find -L "$waybar_styles" -maxdepth 1 -type f \
        -iregex ".*\[${theme}\].*\.css$" 2>/dev/null | shuf -n 1)
    if [ -n "$style_file" ]; then
        ln -sf "$style_file" "$waybar_style_link"
        log "Waybar style → $style_file"
    else
        warn "No Waybar style file found for theme: $theme"
    fi
}
try set_waybar_style "$next_mode"

# ── swaync background colour ──────────────────────────────────────────────────
if [ -f "$swaync_style" ]; then
    if [ "$next_mode" = "Dark" ]; then
        try sed -i '/@define-color noti-bg/s/rgba([^)]*);/rgba(0, 0, 0, 0.8);/' "$swaync_style"
    else
        try sed -i '/@define-color noti-bg/s/rgba([^)]*);/rgba(255, 255, 255, 0.9);/' "$swaync_style"
    fi
else
    warn "swaync style not found: $swaync_style"
fi

# ── ags colours ───────────────────────────────────────────────────────────────
if command -v ags &>/dev/null && [ -f "$ags_style" ]; then
    if [ "$next_mode" = "Dark" ]; then
        try sed -i '/@define-color noti-bg/s/rgba([^)]*);/rgba(0, 0, 0, 0.4);/'         "$ags_style"
        try sed -i '/@define-color text-color/s/rgba([^)]*);/rgba(255, 255, 255, 0.7);/' "$ags_style"
        try sed -i '/@define-color noti-bg-alt/s/#.*;/#111111;/'                          "$ags_style"
    else
        try sed -i '/@define-color noti-bg/s/rgba([^)]*);/rgba(255, 255, 255, 0.4);/'    "$ags_style"
        try sed -i '/@define-color text-color/s/rgba([^)]*);/rgba(0, 0, 0, 0.7);/'      "$ags_style"
        try sed -i '/@define-color noti-bg-alt/s/#.*;/#F0F0F0;/'                          "$ags_style"
    fi
else
    warn "ags not found or style missing — skipping ags colour update"
fi

# ── Wallpaper ─────────────────────────────────────────────────────────────────
if [ ! -d "$wallpaper_dir" ]; then
    die "Wallpaper directory does not exist: $wallpaper_dir"
fi

next_wallpaper="$(find -L "$wallpaper_dir" -type f \
    \( -iname "*.jpg" -o -iname "*.png" \) -print0 2>/dev/null \
    | shuf -n1 -z | xargs -0)"

if [ -z "$next_wallpaper" ]; then
    die "No wallpaper images found in: $wallpaper_dir"
fi

log "Wallpaper → $next_wallpaper"
swww img "$next_wallpaper" \
    --transition-bezier .43,1.19,1,.4 \
    --transition-fps 60 \
    --transition-type grow \
    --transition-pos 0.925,0.977 \
    --transition-duration 2

# ── Kvantum + QT5/QT6 ────────────────────────────────────────────────────────
if [ "$next_mode" = "Dark" ]; then
    kvantum_theme="catppuccin-mocha-blue"
    qt5ct_color_scheme="$HOME/.config/qt5ct/colors/Catppuccin-Mocha.conf"
    qt6ct_color_scheme="$HOME/.config/qt6ct/colors/Catppuccin-Mocha.conf"
else
    kvantum_theme="catppuccin-latte-blue"
    qt5ct_color_scheme="$HOME/.config/qt5ct/colors/Catppuccin-Latte.conf"
    qt6ct_color_scheme="$HOME/.config/qt6ct/colors/Catppuccin-Latte.conf"
fi

if [ -f "$HOME/.config/qt5ct/qt5ct.conf" ]; then
    try sed -i "s|^color_scheme_path=.*$|color_scheme_path=$qt5ct_color_scheme|" \
        "$HOME/.config/qt5ct/qt5ct.conf"
else
    warn "qt5ct.conf not found — skipping"
fi

if [ -f "$HOME/.config/qt6ct/qt6ct.conf" ]; then
    try sed -i "s|^color_scheme_path=.*$|color_scheme_path=$qt6ct_color_scheme|" \
        "$HOME/.config/qt6ct/qt6ct.conf"
else
    warn "qt6ct.conf not found — skipping"
fi

if command -v kvantummanager &>/dev/null; then
    try kvantummanager --set "$kvantum_theme"
else
    warn "kvantummanager not found — skipping Kvantum theme"
fi

# ── Rofi background ───────────────────────────────────────────────────────────
if [ -f "$wallust_rofi" ]; then
    if [ "$next_mode" = "Dark" ]; then
        try sed -i '/^background:/s/.*/background: rgba(0,0,0,0.7);/' "$wallust_rofi"
    else
        try sed -i '/^background:/s/.*/background: rgba(255,255,255,0.9);/' "$wallust_rofi"
    fi
else
    warn "wallust rofi template not found: $wallust_rofi"
fi

# ── GTK themes & icons ────────────────────────────────────────────────────────
set_custom_gtk_theme() {
    local mode="$1"
    local gtk_themes_directory="$HOME/.themes"
    local icon_directory="$HOME/.icons"
    local search_keywords color_setting

    color_setting="org.gnome.desktop.interface color-scheme"

    case "$mode" in
        Light)
            search_keywords="*Light*"
            try gsettings set $color_setting 'prefer-light'
            ;;
        Dark)
            search_keywords="*Dark*"
            try gsettings set $color_setting 'prefer-dark'
            ;;
        *)
            warn "set_custom_gtk_theme: invalid mode '$mode'"
            return 1
            ;;
    esac

    # Collect matching themes and icons into arrays
    mapfile -d '' themes < <(find "$gtk_themes_directory" -maxdepth 1 -type d \
        -iname "$search_keywords" -print0 2>/dev/null)
    mapfile -d '' icons  < <(find "$icon_directory"       -maxdepth 1 -type d \
        -iname "$search_keywords" -print0 2>/dev/null)

    if [ ${#themes[@]} -gt 0 ]; then
        local selected_theme
        selected_theme="$(basename "${themes[RANDOM % ${#themes[@]}]}")"
        log "GTK theme → $selected_theme"
        try gsettings set org.gnome.desktop.interface gtk-theme "$selected_theme"
        if command -v flatpak &>/dev/null; then
            try flatpak --user override --filesystem="$HOME/.themes"
            try flatpak --user override --env=GTK_THEME="$selected_theme"
        fi
    else
        warn "No $mode GTK theme found in $gtk_themes_directory"
    fi

    if [ ${#icons[@]} -gt 0 ]; then
        local selected_icon
        selected_icon="$(basename "${icons[RANDOM % ${#icons[@]}]}")"
        log "Icon theme → $selected_icon"
        try gsettings set org.gnome.desktop.interface icon-theme "$selected_icon"
        for qtconf in "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"; do
            [ -f "$qtconf" ] && try sed -i "s|^icon_theme=.*$|icon_theme=$selected_icon|" "$qtconf"
        done
        if command -v flatpak &>/dev/null; then
            try flatpak --user override --filesystem="$HOME/.icons"
            try flatpak --user override --env=ICON_THEME="$selected_icon"
        fi
    else
        warn "No $mode icon theme found in $icon_directory"
    fi
}

try set_custom_gtk_theme "$next_mode"

# ── wallust + swww colour extraction ─────────────────────────────────────────
if [ -x "${SCRIPTSDIR}/WallustSwww.sh" ]; then
    try "${SCRIPTSDIR}/WallustSwww.sh"
else
    warn "WallustSwww.sh not found or not executable — skipping"
fi

# ── Hard-kill and restart compositor bars/daemons ────────────────────────────
sleep 1
for proc in waybar rofi swaync ags swaybg; do
    killall "$proc" 2>/dev/null || true
done
sleep 0.5

if [ -x "${SCRIPTSDIR}/Refresh.sh" ]; then
    try "${SCRIPTSDIR}/Refresh.sh"
else
    warn "Refresh.sh not found or not executable — skipping"
fi

# ── Final notification ────────────────────────────────────────────────────────
try notify-send -u low -i "$notif" " Themes switched to:" " $next_mode Mode"
log "Done — now in $next_mode mode."
exit 0
