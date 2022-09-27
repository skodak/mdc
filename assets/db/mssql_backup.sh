#!/usr/bin/env bash

if [ ! -d "/backups" ];
then
    echo 'Error: MOODLE_DOCKER_BACKUPS is not mapped to /backups on db'
    exit 1
fi

if [ -z "$1" ];
then
    echo "Backup name is required"
    exit 1
fi

cd /backups
if [ -f "$1_moodledb.bak" ];
then
    rm $1_moodledb.bak
fi

echo "Backing up database into $1_moodledb.bak"

#see https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-backup-and-restore-database?view=sql-server-ver16

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P m@0dl3ing -Q "BACKUP DATABASE [moodle] TO DISK = N'/backups/$1_moodledb.bak' WITH NOFORMAT, NOINIT, NAME = 'moodle-full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
