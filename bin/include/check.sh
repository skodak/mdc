#!/usr/bin/env bash

source "${MDC_BASEDIR}/bin/include/functions.sh"

if [ ! -f "mdc.env" ]; then
    mdc_echo_error "mdc.env file not found in current directory"
    exit 1
fi

if [ ! -f "compose.yaml" ]; then
    mdc_echo_error "missing Docker Compose configuration, run mdc-rebuild first"
    exit 1
fi
