# ===============================
# Backup Automation Module
# ===============================

backup_data() {

    # Ask user which directory to backup
    read -p "Enter full path of directory to backup: " source_dir

    # Check if directory exists
    if [ ! -d "$source_dir" ]; then
        log "ERROR" "Directory does not exist: $source_dir"
        return
    fi

    # Create backups folder if not exists
    mkdir -p backups

    # Create timestamp (Mac compatible)
    timestamp=$(date +%F_%H-%M)

    # Extract folder name only
    folder_name=$(basename "$source_dir")

    # Define backup file name
    backup_file="backups/${folder_name}_backup_${timestamp}.tar.gz"

    # Create compressed archive
    /usr/bin/tar -czf /absolute/path/backups/file.tar.gz

    if [ $? -eq 0 ]; then
        log "INFO" "Backup created successfully: $backup_file"
    else
        log "ERROR" "Backup failed for: $source_dir"
        return
    fi

    # Delete backups older than 7 days (Mac compatible)
    find backups/ -type f -name "*.tar.gz" -mtime +7 -delete

    log "INFO" "Old backups older than 7 days cleaned up"

}