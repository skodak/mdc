#!/usr/bin/env bash

# Check that the configuration file is present,
# stop if not to prevent accidental creation of unwanted containers.
if [ ! -f "mdc.env" ]; then
    echo "ERROR: mdc.env file not found in current directory"
    exit 1
fi
if [ ! -f "${MDC_BASEDIR}/compose-webserver.yml" ]; then
    echo "ERROR: invalid MDC_BASEDIR=$MDC_BASEDIR"
    exit 1
fi

currentdir="$( pwd -P )";
export MDC_PROJECTDIR="$currentdir";

envbackup=$( export -p)
sharedenv="${MDC_BASEDIR}/shared/mdc.env";
if [ -f "$sharedenv" ]; then
    echo "[mdc] Using ${sharedenv}"
    export $(grep -v '^#' $sharedenv | xargs)
fi
export $(grep -v '^#' mdc.env | xargs)
eval "$envbackup"
echo "[mdc] Using ${MDC_PROJECTDIR}/mdc.env"

if [ -z "$MDC_DIRROOT" ]; then
    # We know that mdc.env is in current directory, so use it as default value.
    export MDC_DIRROOT="${MDC_PROJECTDIR}";
fi

# Use current directory name as base for compose project name,
# users need to make sure it is unique enough.
# Unfortunately PhpStorm does not like any prefix in COMPOSE_PROJECT_NAME here.
name="$( basename "$( pwd -P )" )"
name=${name//_/-}
export COMPOSE_PROJECT_NAME="$name";

# Default values - keep them in sync with templates/mdc.env file.

if [ -z "${MDC_BACKUPS_PATH}" ]; then
    export MDC_BACKUPS_PATH="${MDC_BASEDIR}/shared/backups"
fi

export MDC_PHP_VERSION="${MDC_PHP_VERSION:-8.1}"
export MDC_BEHAT_BROWSER="${MDC_BEHAT_BROWSER:-chromium}"
export MDC_BEHAT_BROWSER_VERSION="${MDC_BEHAT_BROWSER_VERSION:-4}"
export MDC_DB_TYPE="${MDC_DB_TYPE:-pgsql}"

if [ "$MDC_DB_TYPE" == "pgsql" ];then
    export MDC_DB_VERSION="${MDC_DB_VERSION:-16}"
elif [ "$MDC_DB_TYPE" == "mysqli" ]; then
    export MDC_DB_VERSION="${MDC_DB_VERSION:-8.4}"
    if [[ "${MDC_DB_VERSION}" == "5.7."* ]]; then
        export MDC_DB_COLLATION="${MDC_DB_COLLATION:-utf8_bin}"
    else
        # TODO: add support for utf8mb4_0900_as_cs collation
        export MDC_DB_COLLATION="${MDC_DB_COLLATION:-utf8mb4_bin}"
    fi
elif [ "$MDC_DB_TYPE" == "mariadb" ]; then
    export MDC_DB_VERSION="${MDC_DB_VERSION:-11.4}"
    # TODO: add support for uca1400_as_cs collations
    export MDC_DB_COLLATION="${MDC_DB_COLLATION:-utf8mb4_bin}"
elif [ "$MDC_DB_TYPE" == "sqlsrv" ]; then
    export MDC_DB_VERSION="${MDC_DB_VERSION:-latest}"
else
    echo "Unknown MDC_DB_TYPE=$MDC_DB_TYPE detected"
    exit 1
fi
