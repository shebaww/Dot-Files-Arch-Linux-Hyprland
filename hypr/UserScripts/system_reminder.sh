#!/bin/bash

# System Reminder Script

# Configuration
NOTIFY=true
LOG_FILE="$HOME/.system_reminder.log"
CONFIG_FILE="$HOME/.config/system_reminder.conf"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Create log file if it doesn't exist
touch "$LOG_FILE"

# Function to log reminders
log_reminder() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="$3"
    
    if [ "$NOTIFY" = true ] && command -v notify-send &> /dev/null; then
        notify-send -u "$urgency" "$title" "$message"
    fi
}

# Function to check if task is due
check_due() {
    local task_name="$1"
    local interval_days="$2"
    local last_run=""
    
    if [ -f "$CONFIG_FILE" ]; then
        last_run=$(grep "^$task_name=" "$CONFIG_FILE" | cut -d'=' -f2)
    fi
    
    if [ -z "$last_run" ]; then
        return 0  # Due (never run)
    fi
    
    local current_time=$(date +%s)
    local last_time=$(date -d "$last_run" +%s 2>/dev/null)
    local days_diff=$(( (current_time - last_time) / 86400 ))
    
    [ $days_diff -ge $interval_days ]
    return $?
}

# Function to update last run time
update_last_run() {
    local task_name="$1"
    local temp_file=$(mktemp)
    
    if [ -f "$CONFIG_FILE" ]; then
        grep -v "^$task_name=" "$CONFIG_FILE" > "$temp_file"
        mv "$temp_file" "$CONFIG_FILE"
    fi
    
    echo "$task_name=$(date +%Y-%m-%d)" >> "$CONFIG_FILE"
}

# Main reminder function
show_reminders() {
    clear
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    SYSTEM MAINTENANCE REMINDER                   ${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local current_day=$(date +%u)  # 1-7 (Monday-Sunday)
    local current_date=$(date +%Y-%m-%d)
    local current_time=$(date +%H:%M)
    
    echo -e "${YELLOW}Current Date:${NC} $current_date"
    echo -e "${YELLOW}Current Time:${NC} $current_time"
    echo -e "${YELLOW}Day of Week:${NC} $(date +%A)"
    echo ""
    
    # Daily GitHub Portfolio Reminder
    echo -e "${GREEN}📦 DAILY TASK:${NC}"
    echo -e "   ${BLUE}● GitHub Portfolio Update${NC}"
    echo -e "     └─ Make at least one contribution to your portfolio today!"
    echo ""
    send_notification "Daily Reminder" "Update your GitHub portfolio today!" "normal"
    log_reminder "Daily GitHub reminder shown"
    
    # Check weekly tasks (Saturday = day 6)
    if [ "$current_day" -eq 6 ]; then
        echo -e "${GREEN}📅 WEEKLY TASKS (Saturday):${NC}"
        
        # Pacman update
        echo -e "   ${BLUE}● Pacman System Update${NC}"
        echo -e "     └─ Run: ${CYAN}sudo pacman -Syu${NC}"
        echo ""
        
        # Rice laptop
        echo -e "   ${BLUE}● Rice Your Laptop${NC}"
        echo -e "     └─ Time to customize and beautify your system!"
        echo -e "     └─ Check: themes, icons, conky, polybar, etc."
        echo ""
        
        send_notification "Weekly Reminder" "Time for system update and ricing!" "normal"
        log_reminder "Weekly tasks reminder shown"
    fi
    
    # Check monthly tasks
    if check_due "monthly_maintenance" 30; then
        echo -e "${GREEN}📆 MONTHLY TASKS:${NC}"
        
        # Backup reminder
        echo -e "   ${BLUE}● System Backup${NC}"
        echo -e "     └─ Options:"
        echo -e "        • Clonezilla (full system backup)"
        echo -e "        • BackInTime (file backup)"
        echo ""
        
        # Clean packages/debloat
        echo -e "   ${BLUE}● Package Cleanup & Debloat${NC}"
        echo -e "     └─ Commands to run:"
        echo -e "        • ${CYAN}sudo pacman -Sc${NC} (clean package cache)"
        echo -e "        • ${CYAN}sudo pacman -Rns $(pacman -Qdtq)${NC} (remove orphans)"
        echo -e "        • ${CYAN}pamac clean${NC} (if using pamac)"
        echo -e "        • ${CYAN}yay -Sc${NC} (if using yay)"
        echo ""
        
        # Combined backup and debloat
        echo -e "   ${BLUE}● Backup & Debloat Combo${NC}"
        echo -e "     └─ Complete system maintenance session"
        echo ""
        
        send_notification "Monthly Reminder" "Time for system backup and cleanup!" "critical"
        log_reminder "Monthly tasks reminder shown"
        update_last_run "monthly_maintenance"
    fi
    
    # Show last log entries
    if [ -f "$LOG_FILE" ]; then
        echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Recent Reminder History:${NC}"
        tail -n 5 "$LOG_FILE" | while read line; do
            echo -e "  ${CYAN}↳${NC} $line"
        done
    fi
    
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}Press any key to exit...${NC}"
    read -n 1
}

# Run the reminder
show_reminders
