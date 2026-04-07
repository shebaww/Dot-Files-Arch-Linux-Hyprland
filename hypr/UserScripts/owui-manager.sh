#!/usr/bin/env bash

# ---- Configuration ----
OWUI_CONTAINER="open-webui"
OWUI_PORT=3000
OLLAMA_PORT=11434
NOTIFY_TIMEOUT=3000

# Choose your menu tool (uncomment one):
# ROFI (X11/Wayland compatible)
MENU_TOOL="rofi -dmenu -p 'OWUI:' -lines 6"
# FUZZEL (Wayland native)
# MENU_TOOL="fuzzel -d -l 6 -p 'OWUI:'"
# WOFI (Wayland native)
# MENU_TOOL="wofi --dmenu -p 'OWUI:' -L 6"
# BEMENU (Wayland native)
# MENU_TOOL="bemenu -p 'OWUI:' -l 6"

# ---- Functions ----
show_menu() {
    local options=(
        "1) Start Open WebUI with Ollama"
        "2) Start Open WebUI without Ollama"
        "3) Stop Open WebUI (keep Ollama)"
        "4) Stop Open WebUI and Ollama"
        "5) Check status"
        "6) Open in browser"
    )
    
    printf "%s\n" "${options[@]}" | eval "$MENU_TOOL"
}

notify() {
    local message="$1"
    local timeout="${2:-$NOTIFY_TIMEOUT}"
    if command -v notify-send &> /dev/null; then
        notify-send -t "$timeout" "OWUI Manager" "$message"
    else
        echo "OWUI: $message"
    fi
}

check_status() {
    local owui_status="✗ Not running"
    local ollama_status="✗ Not running"
    
    # Check Open WebUI
    if docker ps --format '{{.Names}}' | grep -q "^${OWUI_CONTAINER}$"; then
        owui_status="✓ Running (http://localhost:${OWUI_PORT})"
    fi
    
    # Check Ollama
    if curl -s http://127.0.0.1:${OLLAMA_PORT}/api/tags >/dev/null 2>&1; then
        ollama_status="✓ Running"
    fi
    
    notify "Open WebUI: $owui_status\nOllama: $ollama_status" 5000
}

start_with_ollama() {
    notify "Starting Ollama and Open WebUI..."
    
    # Start Ollama if not running
    if ! curl -s http://127.0.0.1:${OLLAMA_PORT}/api/tags >/dev/null 2>&1; then
        OLLAMA_HOST=0.0.0.0 ollama serve >/dev/null 2>&1 &
        sleep 3
        notify "Ollama started"
    else
        notify "Ollama already running"
    fi
    
    # Remove existing container
    docker rm -f ${OWUI_CONTAINER} >/dev/null 2>&1 || true
    
    # Start Open WebUI
    docker run -d \
  -p ${OWUI_PORT}:8080 \
  --health-cmd="exit 0" \
   -e WEBUI_AUTH=False \
   -e RAG_EMBEDDING_MODEL_AUTO_UPDATE=False \
   -e ENABLE_RAG_WEB_SEARCH=False \
    -v open-webui:/app/backend/data \
  --add-host=host.docker.internal:host-gateway \
  -e OLLAMA_BASE_URL=http://host.docker.internal:${OLLAMA_PORT} \
  --name ${OWUI_CONTAINER} \
  ghcr.io/open-webui/open-webui:main >/dev/null

    sleep 2
    notify "Open WebUI with Ollama available at http://localhost:${OWUI_PORT}"
}

start_without_ollama() {
    notify "Starting Open WebUI without Ollama..."
    
    # Remove existing container
    docker rm -f ${OWUI_CONTAINER} >/dev/null 2>&1 || true
    
    # Start Open WebUI without Ollama config
    docker run -d \
      -p ${OWUI_PORT}:8080 \
      --health-cmd="exit 0" \
      -v open-webui:/app/backend/data \
      --name ${OWUI_CONTAINER} \
      ghcr.io/open-webui/open-webui:main >/dev/null
    
    sleep 2
    notify "Open WebUI available at http://localhost:${OWUI_PORT}"
}

stop_owui_only() {
    if docker ps --format '{{.Names}}' | grep -q "^${OWUI_CONTAINER}$"; then
        docker rm -f ${OWUI_CONTAINER} >/dev/null 2>&1
        notify "Open WebUI stopped. Ollama is still running."
    else
        notify "Open WebUI is not running."
    fi
}

stop_all() {
    # Stop Open WebUI
    docker rm -f ${OWUI_CONTAINER} >/dev/null 2>&1 || true
    
    # Stop Ollama
    if pkill ollama >/dev/null 2>&1; then
        notify "Open WebUI and Ollama stopped."
    else
        notify "Open WebUI stopped. Ollama was not running."
    fi
}

open_browser() {
    if docker ps --format '{{.Names}}' | grep -q "^${OWUI_CONTAINER}$"; then
        # Try different browser commands
        librewolf "http://localhost:${OWUI_PORT}" 2>/dev/null || \
        sensible-browser "http://localhost:${OWUI_PORT}" 2>/dev/null || \
        notify "Could not open browser. Please visit: http://localhost:${OWUI_PORT}"
    else
        notify "Open WebUI is not running. Please start it first."
    fi
}

# ---- Main ----
choice=$(show_menu)

case "$choice" in
    *"Start Open WebUI with Ollama"*|*"1)"*)
        start_with_ollama
        ;;
    *"Start Open WebUI without Ollama"*|*"2)"*)
        start_without_ollama
        ;;
    *"Stop Open WebUI (keep Ollama)"*|*"3)"*)
        stop_owui_only
        ;;
    *"Stop Open WebUI and Ollama"*|*"4)"*)
        stop_all
        ;;
    *"Check status"*|*"5)"*)
        check_status
        ;;
    *"Open in browser"*|*"6)"*)
        open_browser
        ;;
    *)
        # User cancelled or closed the menu
        exit 0
        ;;
esac
