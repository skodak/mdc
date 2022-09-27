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
if [ ! -f "$1_moodledb.gz" ];
then
    echo "Backup file not present: $1_moodledb.gz"
fi

echo "Restoring database from $1_moodledb.gz"

gunzip -c $1_moodledb.gz | psql -h127.0.0.1 -U moodle -q postgres
