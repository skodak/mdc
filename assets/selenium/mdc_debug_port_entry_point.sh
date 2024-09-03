#!/usr/bin/env bash

if ! dpkg-query -l socat > dev/null; then
    sudo apt-get update -qqy
    sudo apt-get -qqy --no-install-recommends install socat
fi

source /opt/bin/entry_point.sh
