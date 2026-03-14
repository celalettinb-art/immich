#!/bin/bash
# If not installed, install cifs-utils: apt install -y cifs-utils zip
# Create log file (once): touch /var/log/smb_backup.log
# Modify permissions for the created smb_backup.log file: chmod 600 /var/log/smb_backup.log
# Create credential file: nano /root/.smbcredentials
## Add and customize the lines below:
#     username=USERNAME
#     password=PASSWORD
#     domain=WORKGROUP # optional
# Modify permissions for the created .smbcredentials file: chmod 600 /root/.smbcredentials
# Create a file in /root/ with the name backup-immich.sh and add this script content: nano /root/backup-immich.sh
# Make the script executable: chmod +x /root/backup-immich.sh
# Cronjob: 0 4 * * 0 /root/backup-immich.sh >> /var/log/smb_backup.log 2>&1
# List Cronjobs: crontab -l | Edit Cronjobs crontab -e
# Test by executing manually: /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bi  /root/backup-immich.sh  >> /var/log/smb_backup.log 2>&1
## Read logs:
#    tail -n 50 /var/log/smb_backup.log
#    tail -f /var/log/smb_backup.log (live)
#    grep CRON /var/log/syslog
#    journalctl -u cron -f
## Clean up old backup files on Windows, where the SMB share is running, with a Powershell script:
#     $date = (Get-Date).AddDays(-31)
#     Get-ChildItem D:\Backup\immich | Where-Object {$_.LastWriteTime -lt $date} | Remove-Item -Force

set -e

# CONFIGURATION
DATE=$(date +%Y-%m-%d)
SERVER="//IP_ADDRESS/Backup"
TMP_BACKUP_DIR="/tmp/immich-backup"
BACKUP_FILE="export_${DATE}.zip"
REMOTE_DIR="immich" 
CREDS="/root/.smbcredentials"

# Folders to back up
DIR1="/opt/immich/upload/library/admin"
DIR2="/opt/immich/upload/backups"

# BACKUP START
echo "==== Immich Backup has started: $(date) ===="

# Prepare the Temp directory
mkdir -p "$TMP_BACKUP_DIR"

# Create ZIP
echo "Create ZIP archive..."

zip -r "${TMP_BACKUP_DIR}/${BACKUP_FILE}" \
    "$DIR1" \
    "$DIR2"

echo "ZIP created: ${TMP_BACKUP_DIR}/${BACKUP_FILE}"

# UPLOAD TO SMB
echo "Upload backup to SMB share..."

smbclient "$SERVER" -A="$CREDS" -c "cd $REMOTE_DIR; put $TMP_BACKUP_DIR/$BACKUP_FILE $BACKUP_FILE"

echo "Upload succesfully."

# CLEAN
rm -f "${TMP_BACKUP_DIR}/${BACKUP_FILE}"

echo "Temporary files have been deleted."

echo "==== Backup complete: $(date) ===="
