#!/usr/bin/env bash

echo 'Waiting for MariaDB to come up...'
until mysql -h 127.0.0.1 --user=moodle --password="m@0dl3ing" moodle -e "SELECT 'moodle_user_present';" 2> /dev/null| grep -q 'moodle_user_present';
do
    sleep 1
done
echo 'MariaDB is accepting network connections now.'



