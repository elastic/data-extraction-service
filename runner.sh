#!/bin/sh
set -e

# Clear OpenRC crashed/started state to allow fresh start
rc-service tika zap 2>/dev/null || true
rc-service openresty zap 2>/dev/null || true

echo "Service 'All': Status"
rc-status -a
rc-update add tika boot
rc-update add openresty boot

echo "Service 'Tika': Starting ..."
rc-service tika start

echo "Service 'Openresty': Starting ..."
rc-service openresty start

# keep alive (TODO convert to health check)
while true; do sleep 1; done;