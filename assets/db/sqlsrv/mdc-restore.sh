#!/usr/bin/env bash
set -e

if [ ! -d "/var/backups" ];
then
    echo 'Error: MDC_BACKUP_PATH is not mapped to /var/backups on db'
    exit 1
fi

if [ -z "$1" ];
then
    echo "Backup name is required"
    exit 1
fi

cd /var/backups
if [ ! -f "$1_moodledb.bak" ];
then
    echo "Backup file not present: $1_moodledb.bak"
fi

echo "Restoring database from $1_moodledb.bak"

#see https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-backup-and-restore-database?view=sql-server-ver16

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P m@0dl3ing -Q "RESTORE DATABASE [moodle] FROM DISK = N'/var/backups/$1_moodledb.bak' WITH FILE = 1, NOUNLOAD, REPLACE, STATS = 5"
