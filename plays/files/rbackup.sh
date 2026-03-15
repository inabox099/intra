#!/bin/bash

# Script: rbackup.sh
# Description: Skeleton shell script with logging and parameter support
# Author: [Your Name]
# Date: [Date]

# Variables
LOG_FILE="rbackup.log"
QUIET_MODE=true


REMOTE_USER="ansuser"
REMOTE_HOST="192.168.0.70"
REMOTE_DIR="/export/home/backup/$HOSTNAME"

# Functions
log_message() {
    local MESSAGE="$1"
    local TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "$TIMESTAMP - $MESSAGE" >> "$LOG_FILE"
    if [ "$QUIET_MODE" = false ]; then
        echo "$TIMESTAMP - $MESSAGE"
    fi
}

# Parse Parameters
while getopts "u:q" OPTION; do
    case $OPTION in
        u)
            USERNAME="$OPTARG"
            REMOTE_DIR="$REMOTE_DIR/$USERNAME"
            ;;
        q)
            QUIET_MODE=true
            ;;
        *)
            echo "Usage: $0 [-q]"
            exit 1
            ;;
    esac
done


backup_to_remote() {

    if [ -z "$USERNAME" ] || [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_DIR" ]; then
        log_message "Error: Missing arguments for backup_to_remote function."
        return 1
    fi

    local SOURCE_DIR="/home/$USERNAME"
    if [ ! -d "$SOURCE_DIR" ]; then
        log_message "Error: Source directory $SOURCE_DIR does not exist."
        return 1
    fi

    log_message "Starting backup of $SOURCE_DIR to $REMOTE_HOST:$REMOTE_DIR"
    rsync -avz --delete --exclude '.steam' --exclude ".local" --exclude ".cache" --exclude ".cargo" --exclude .vscode --exclude .venv --exclude _venv -e "ssh -l $REMOTE_USER" "$SOURCE_DIR" "$REMOTE_HOST:$REMOTE_DIR"
    if [ $? -eq 0 ]; then
        log_message "Backup completed successfully."
    else
        log_message "Error: Backup failed."
        return 1
    fi
}
# Main Script
log_message "Script started."
backup_to_remote
if [ $? -ne 0 ]; then
    log_message "Backup process encountered errors."
    exit 1
fi
# Add your script logic here

log_message "Script finished."
exit 0