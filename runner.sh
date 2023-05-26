#!/bin/sh
set -e

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