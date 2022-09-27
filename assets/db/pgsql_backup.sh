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
if [ -f "$1_moodledb.gz" ];
then
    rm $1_moodledb.gz
fi

echo "Backing up database into $1_moodledb.gz"

pg_dump moodle -h127.0.0.1 -U moodle --create --clean | gzip -c > $1_moodledb.gz
