#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##

# GDK BACKEND. Change to either wayland or x11 if having issues
BACKEND=wayland

# Check if rofi or yad is running and kill them if they are
if pidof rofi > /dev/null; then
  pkill rofi
fi

if pidof yad > /dev/null; then
  pkill yad
fi

# Launch yad with calculated width and height
GDK_BACKEND=$BACKEND yad \
    --center \
    --title="KooL Quick Cheat Sheet" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
"ESC" "close this app" "" \
" = " "SUPER KEY (Windows Key Button)" "(SUPER KEY)" \
"" "" "" \
" SHIFT K" "Searchable Keybinds" "(Search all Keybinds via rofi)" \
" SHIFT E" "Opens CLI File manager" "yazi" \
" Q" "Close active window (graceful)" "killactive" \
" SHIFT Q" "Kill active process (force)" "KillActiveProcess.sh" \
"CTRL ALT L" "Screen lock" "swaylock-fancy" \
"CTRL ALT P" "Power menu" "wlogout" \
" SHIFT N" "Toggle notification panel" "swaync-client -t -sw" \
" SHIFT M" "Opens dock and closes waybar" "cairo-dock.sh" \
"" "" "" \
" Return" "Terminal" "(kitty)" \
" SHIFT Return" "DropDown Terminal" " Q to close" \
" B" "Launch Browser" "(librewolf)" \
" D" "Application Launcher" "(rofi-wayland)" \
" E" "Open File Manager" "(Thunar)" \
" A" "Desktop Overview" "(AGS/Quickshell)" \
" S" "Google Search using rofi" "(rofi)" \
" ALT V" "Clipboard Manager" "(cliphist)" \
" ALT E" "Rofi Emoticons" "(Emoji picker)" \
" ALT C" "Calculator" "(RofiCalc.sh - qalculate)" \
" CTRL G" "Open Note Editor" "(gedit)" \
"" "" "" \
" W" "Choose wallpaper" "(WallpaperSelect.sh)" \
" SHIFT W" "Choose wallpaper effects" "(imagemagick + swww)" \
"CTRL ALT W" "Random wallpaper" "(WallpaperRandom.sh)" \
" ALT O" "Toggle Blur" "(ChangeBlur.sh)" \
" SHIFT A" "Animations Menu" "(Animations.sh)" \
" SHIFT G" "Gamemode! All animations OFF or ON" "(GameMode.sh)" \
"" "" "" \
" [0-9]" "Switch to workspace" "(1-10)" \
" SHIFT [0-9]" "Move window to workspace + follow" "(1-10)" \
" CTRL [0-9]" "Move window to workspace silently" "(1-10)" \
" SHIFT [" "Move window to previous workspace + follow" "" \
" SHIFT ]" "Move window to next workspace + follow" "" \
" CTRL [" "Move window to previous workspace silently" "" \
" CTRL ]" "Move window to next workspace silently" "" \
" Tab" "Next workspace" "workspace m+1" \
" SHIFT Tab" "Previous workspace" "workspace m-1" \
" . (period)" "Next existing workspace" "workspace e+1" \
" , (comma)" "Previous existing workspace" "workspace e-1" \
" mouse scroll" "Scroll through workspaces" "" \
" U" "Toggle special workspace (scratchpad)" "" \
" SHIFT U" "Move to special workspace" "" \
"" "" "" \
" arrow keys" "Move focus to window" "(movefocus)" \
" CTRL arrow" "Move window in layout" "(movewindow)" \
" ALT arrow" "Swap window positions" "(swapwindow)" \
" SHIFT arrow" "Resize window (hold)" "(resizeactive ±50)" \
" SPACE" "Toggle float (single window)" "togglefloating" \
" ALT SPACE" "Toggle all windows to float" "workspaceopt allfloat" \
" SHIFT F" "Fullscreen (true)" "fullscreen" \
" CTRL F" "Fake Fullscreen" "fullscreen, 1" \
" M" "Change split ratio to 0.3" "splitratio 0.3" \
" P" "Pseudo-tile (Dwindle)" "pseudo" \
" SHIFT I" "Toggle split (Dwindle)" "togglesplit" \
" G" "Toggle window group (tabbed mode)" "togglegroup" \
" CTRL Tab" "Change active tab in group" "changegroupactive" \
"ALT Tab" "Cycle through floating windows" "cyclenext + bringactivetotop" \
" CTRL O" "Toggle opaque on active window" "setprop active opaque toggle" \
"" "" "" \
" I" "Add current window as master" "addmaster" \
" CTRL D" "Remove current window as master" "removemaster" \
" J" "Cycle to next window" "cyclenext" \
" K" "Cycle to previous window" "cycleprev" \
" CTRL Return" "Swap with master" "swapwithmaster" \
" ALT L" "Toggle Dwindle | Master Layout" "ChangeLayout.sh" \
"" "" "" \
" + left click (drag)" "Move floating window" "" \
" + right click (drag)" "Resize floating window" "" \
"" "" "" \
" Print" "Screenshot entire screen" "(grim)" \
" SHIFT Print" "Screenshot region" "(grim + slurp)" \
" CTRL Print" "Screenshot with 5 sec delay" "(grim)" \
" CTRL SHIFT Print" "Screenshot with 10 sec delay" "(grim)" \
"ALT Print" "Screenshot active window only" "" \
" SHIFT S" "Screenshot region with swappy" "(swappy editor)" \
"" "" "" \
"Volume Up key" "Increase volume" "Volume.sh --inc" \
"Volume Down key" "Decrease volume" "Volume.sh --dec" \
"Mute key" "Toggle mute" "Volume.sh --toggle" \
"Mic Mute key" "Toggle microphone mute" "Volume.sh --toggle-mic" \
"Play/Pause key" "Play/Pause media" "MediaCtrl.sh --pause" \
"Next Track key" "Next track" "MediaCtrl.sh --nxt" \
"Previous Track key" "Previous track" "MediaCtrl.sh --prv" \
"Stop key" "Stop media" "MediaCtrl.sh --stop" \
"Sleep button" "Suspend system" "systemctl suspend" \
"Rfkill key" "Toggle airplane mode" "AirplaneMode.sh" \
"" "" "" \
" CTRL ALT B" "Hide/UnHide Waybar" "pkill -SIGUSR1 waybar" \
" CTRL B" "Choose waybar styles" "WaybarStyles.sh" \
" ALT B" "Choose waybar layout" "WaybarLayout.sh" \
" ALT R" "Reload Waybar, swaync, Rofi" "Refresh.sh" \
"" "" "" \
" CTRL R" "Rofi Themes Menu" "RofiThemeSelector.sh" \
" CTRL SHIFT R" "Rofi Themes Menu v2 (modified)" "RofiThemeSelector-modified.sh" \
"" "" "" \
" SHIFT O" "Change ZSH Theme" "ZshChangeTheme.sh" \
" SHIFT K" "Search keybinds via rofi" "KeyBinds.sh" \
" CTRL SHIFT H" "Toggle hotspot" "hotspot-toggle.sh" \
" CTRL S" "Manage open-webui and ollama" "owui-manager.sh" \
"ALT_L + SHIFT_L" "Change keyboard layout (global)" "SwitchKeyboardLayout.sh" \
"SHIFT_L + ALT_L" "Change keyboard layout (per window)" "Tak0-Per-Window-Switch.sh" \
" T" "Toggle Light/Dark Mode" "DarkLight.sh" \
" ALT mouse scroll" "Desktop Zoom (in/out)" "cursor:zoom_factor" \
" H" "Launch this Quick Cheat Sheet" "KeyHints.sh" \
"" "" "" \
"More tips:" "https://github.com/JaKooLit/Hyprland-Dots/wiki" "" \
