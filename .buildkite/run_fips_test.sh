#!/bin/bash

# !!! WARNING DO NOT add -x to avoid leaking vault passwords
set -euo pipefail

echo "=== Building FIPS Docker image ==="
docker build -f Dockerfile.fips -t extraction-service-fips .

echo "=== Running FIPS e2e tests ==="
make fips-e2e
