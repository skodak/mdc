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
if [ -f "$1_moodledb.gz" ];
then
    rm $1_moodledb.gz
fi

echo "Backing up database into $1_moodledb.gz"

export MYSQL_PWD=m@0dl3ing
mysqldump --user=root --add-drop-database --databases moodle | gzip -c > $1_moodledb.gz
