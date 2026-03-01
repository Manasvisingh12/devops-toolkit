check_service() {
    service_name=$1

    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-active --quiet "$service_name"; then
            log "INFO" "$service_name is running"
        else
            log "WARNING" "$service_name is down. Attempting restart..."
            systemctl restart "$service_name"
        fi
    else
        log "ERROR" "systemctl not available on this system"
    fi
}