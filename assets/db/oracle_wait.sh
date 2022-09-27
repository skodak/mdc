#!/usr/bin/env bash

echo 'Waiting for oracle to come up...'

oraclecommand="timeout 5 sqlplus -S sys/oracle@127.0.0.1 as sysdba @mdc_db_wait.sql"
until $oraclecommand | grep -q 'moodle_user_present';
do
    echo 'Waiting for oracle to come up...'
    sleep 2
done
