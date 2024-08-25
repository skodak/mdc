#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install socat

sudo socat TCP4-LISTEN:9223,fork TCP4:127.0.0.1:9222
