#!/usr/bin/env bash

if [ ! -d "/backups" ];
then
    echo 'Error: MDC_BACKUPS_PATH is not mapped to /backups on db'
    exit 1
fi

if [ -z "$1" ];
then
    echo "Backup name is required"
    exit 1
fi

cd /backups
if [ -f "$1_moodledb.gz" ];
then
    rm $1_moodledb.gz
fi

echo "Backing up database into $1_moodledb.gz"

export MYSQL_PWD=m@0dl3ing
mysqldump --user=root --add-drop-database --databases moodle | gzip -c > $1_moodledb.gz
