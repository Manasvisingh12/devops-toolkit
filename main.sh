#!/bin/bash

# ==============================
# DevOps Toolkit - Production Version
# macOS Compatible
# ==============================

# ---- Strict Mode ----
set -euo pipefail
IFS=$'\n\t'

# ---- Absolute Paths (macOS default) ----
DATE_BIN="/bin/date"
TAR_BIN="/usr/bin/tar"
FIND_BIN="/usr/bin/find"
RM_BIN="/bin/rm"
CURL_BIN="/usr/bin/curl"

# ---- Configuration ----
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_SOURCE="$BASE_DIR/important_data"
BACKUP_DIR="$BASE_DIR/backups"
LOG_FILE="$BASE_DIR/toolkit.log"

# ---- Logging Function ----
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$($DATE_BIN '+%Y-%m-%d %H:%M:%S')

    echo "$timestamp [$level] $message" | tee -a "$LOG_FILE"

    if [[ "$level" == "ERROR" ]]; then
        send_alert "$timestamp [$level] $message"
    fi
}

# ---- Signal Handling ----
cleanup() {
    log "INFO" "Script interrupted. Cleaning up before exit..."
    exit 1
}

trap cleanup SIGINT SIGTERM

# ---- Root Check ----
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Please run as root (sudo)"
    exit 1
fi

# ---- Path Validation ----
validate_path() {
    local target="$1"

    if [[ -z "$target" ]]; then
        log "ERROR" "Path cannot be empty"
        exit 1
    fi

    case "$target" in
        "/"|"/System"|"/bin"|"/usr"|"/etc")
            log "ERROR" "Dangerous path detected: $target"
            exit 1
            ;;
    esac
}

# ---- Email / Webhook Alert (Optional) ----
send_alert() {
    local message="$1"

    # Uncomment and configure Slack webhook if needed
    # $CURL_BIN -X POST -H 'Content-type: application/json' \
    # --data "{\"text\":\"$message\"}" \
    # https://hooks.slack.com/services/YOUR/WEBHOOK/URL

    echo "ALERT: $message"
}

# ---- Create Backup ----
create_backup() {

    log "INFO" "Starting backup process"

    validate_path "$BACKUP_SOURCE"
    validate_path "$BACKUP_DIR"

    if [[ ! -d "$BACKUP_SOURCE" ]]; then
        log "ERROR" "Backup source directory does not exist"
        exit 1
    fi

    mkdir -p "$BACKUP_DIR"

    timestamp=$($DATE_BIN +%F_%H-%M)
    backup_file="$BACKUP_DIR/backup_$timestamp.tar.gz"

    $TAR_BIN -czf "$backup_file" "$BACKUP_SOURCE"

    log "INFO" "Backup created: $backup_file"
}

# ---- Cleanup Old Backups ----
cleanup_old_backups() {

    log "INFO" "Deleting backups older than 30 days"

    validate_path "$BACKUP_DIR"

    if [[ -d "$BACKUP_DIR" ]]; then
        $FIND_BIN "$BACKUP_DIR" -type f -mtime +30 -print -delete
        log "INFO" "Old backup files deleted"
    else
        log "INFO" "No backup directory found"
    fi
}

# ---- Main Execution ----
main() {

    log "INFO" "===== DevOps Toolkit Started ====="

    create_backup
    cleanup_old_backups

    log "INFO" "===== DevOps Toolkit Completed Successfully ====="
}

main

read -p "Press Enter to continue..."