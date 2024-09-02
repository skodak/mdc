#!/usr/bin/env bash

echo "##### MDC - Selenium debug port redirection via socat #####"
socat TCP-LISTEN:9229,fork TCP4:127.0.0.1:9222
