#!/usr/bin/env bash
set -e
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

export MOODLE_DOCKER_WWWROOT="${basedir}/moodle"

if [ "$SUITE" = "phpunit" ];
then
    initcmd="bin/mdc exec -T webserver php admin/tool/phpunit/cli/init.php"
elif [ "$SUITE" = "phpunit-full" ];
then
    export MOODLE_DOCKER_PHPUNIT_EXTERNAL_SERVICES=true
    initcmd="bin/mdc exec -T webserver php admin/tool/phpunit/cli/init.php"
else
    echo "Error, unknown suite '$SUITE'"
    exit 1
fi

echo "Pulling docker images"
$basedir/bin/mdc pull
echo "Starting up container"
$basedir/bin/mdc up -d
echo "Waiting for DB to come up"
$basedir/bin/moodle-docker-wait-for-db
echo "Running: $initcmd"
$basedir/$initcmd
