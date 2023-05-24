#!/bin/bash

set -e

echo "Logging you out from Docker..."
docker logout docker.elastic.co
echo "Done!"
echo