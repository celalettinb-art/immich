#!/bin/bash
# If not installed, install cifs-utils: apt install -y cifs-utils zip smbclient
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
# List Cronjobs: crontab -l
# Edit Cronjobs: crontab -e
# Test by executing manually: /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bi  /root/backup-immich.sh  >> /var/log/smb_backup.log 2>&1
## Read logs:
#    tail -n 50 /var/log/smb_backup.log
#    tail -f /var/log/smb_backup.log (live)
#    grep CRON /var/log/syslog
#    journalctl -u cron -f
## Clean up old backup files on Windows, where the SMB share is running, with a Powershell script:
# Set the path to the folder
#    $folder = "C:\Path\to\folder"
#    # Get all files in the folder (no subfolders) and sort by last write time (oldest first)
#    $files = Get-ChildItem -Path $folder -File | Sort-Object LastWriteTime
#    # Continue only if more than one file exists
#    if ($files.Count -gt 1) {
#        # Delete all files except the newest one
#        # Because of ascending sort: remove all except the last element
#        $files[0..($files.Count - 2)] | Remove-Item -Force
#    }

set -e

# CONFIGURATION
SERVER="//IP_ADDRESS/Backup"
CREDS="/root/.smbcredentials"
DIR1="/opt/immich/upload/library/admin"
DIR2="/opt/immich/upload/backups"

# BACKUP START
tar czf - -C $DIR1 $DIR2 | smbclient $SERVER -A $CREDS -c "cd immich; put - immich-backup-$(date +%F).tar.gz"
