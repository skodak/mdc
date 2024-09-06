#!/usr/bin/env bash

if [ ! -d "/var/backups" ];
then
    echo 'Error: MDC_BACKUP_PATH is not mapped to /var/backups on webserver'
    exit 1
fi

if [ -z "$1" ];
then
    echo "Backup name is required"
    exit 1
fi

cd /var/backups
if [ -f "$1_moodledata.tgz" ];
then
    rm $1_moodledata.tgz
fi

echo "Backing up web server dataroot into $1_moodledata.tgz"

tar -zcpf $1_moodledata.tgz /var/www/moodledata /var/www/behatdata /var/www/phpunitdata
