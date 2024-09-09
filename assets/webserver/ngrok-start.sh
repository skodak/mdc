#!/usr/bin/env bash

if [ -z "$1" ]; then
    ngrok http 80
else
    ngrok http --domain=$1 80
fi