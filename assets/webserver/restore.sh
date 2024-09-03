#!/usr/bin/env bash

if [ ! -d "/var/www/backups" ];
then
    echo 'Error: MDC_BACKUP_PATH is not mapped to /var/www/backups on webserver'
    exit 1
fi

if [ -z "$1" ];
then
    echo "Backup name is required"
    exit 1
fi

cd /

if [ ! -f "/var/www/backups/$1_moodledata.tgz" ];
then
    echo "Backup file not present: $1_moodledata.tgz"
    exit 1
fi

echo "Restoring web server dataroot from $1_moodledata.tgz"

rm -rf /var/www/moodledata/*
rm -rf /var/www/behatdata/*
rm -rf /var/www/phpunitdata/*

tar -xpzf /var/www/backups/$1_moodledata.tgz var/www/moodledata var/www/behatdata var/www/phpunitdata -C /

if [ -f "/var/www/phpunitdata/.htaccess" ];
then
    rm /var/www/phpunitdata/.htaccess
fi
