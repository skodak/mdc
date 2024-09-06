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
if [ ! -f "$1_moodledb.gz" ];
then
    echo "Backup file not present: $1_moodledb.gz"
fi

echo "Restoring database from $1_moodledb.gz"

export MYSQL_PWD=m@0dl3ing
gunzip -c $1_moodledb.gz | mysql --user=root moodle
