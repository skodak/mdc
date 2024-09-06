#!/usr/bin/env bash

echo -n '[mdc] Waiting for MariaDB to come up '
until mariadb -h 127.0.0.1 --user=moodle --password="m@0dl3ing" moodle -e "SELECT 'moodle_user_present';" 2> /dev/null| grep -q 'moodle_user_present';
do
    echo -n '.'
    sleep 1
done
echo ' Ready!';



