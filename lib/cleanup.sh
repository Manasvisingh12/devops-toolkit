cleanup_old_files(){
    LOG_DIR="logs"
    BACKUP_DIR="backups"
    log "INFO" "Starting cleanup process "
    if [! -d "$LOG_DIR"]; then 
    log "WARNING" "Log directory does not exist"
    else
    find "$LOG_DIR" -type f -name "*.log" -mtime +30 -delete
    log "INFO" "Old log files older than 30 deleted"
    fi
    if [! -d "$BACKUP_DIR"]; then 
    log "WARNING" "BACKUP DIRECTORY DOES NOT EXIST"
    else
    find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +30 -print -delete 
    log "INFO" "OLD backups files older than 30 days are deleted"
    fi
    log "INFO" "Cleanup process completed"
}