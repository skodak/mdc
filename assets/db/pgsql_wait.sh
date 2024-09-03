#!/usr/bin/env bash

echo '[mdc] Waiting for PostgreSQL to come up...'
until psql -U moodle -h 127.0.0.1 -c "SELECT 'moodle_user_present'" 2> /dev/null| grep -q 'moodle_user_present';
do
    sleep 1
done
echo '[mdc] PostgreSQL is accepting network connections now.'


