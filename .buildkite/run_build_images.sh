#!/bin/bash

# !!! WARNING DO NOT add -x to avoid leaking vault passwords
set -euo pipefail

echo "=== Building Docker images ==="
docker build -f Dockerfile.fips -t extraction-service-fips .
docker build -t extraction-service .

echo "=== Saving image as artifacts ==="
mkdir -p .artifacts
docker save extraction-service-fips | gzip >.artifacts/extraction-service-fips.tar.gz
docker save extraction-service | gzip >.artifacts/extraction-service.tar.gz

echo "=== Image built and saved ==="
docker images extraction-service-fips
docker images extraction-service
ls -lh .artifacts/extraction-service*.tar.gz
