#!/bin/bash

# !!! WARNING DO NOT add -x to avoid leaking vault passwords
set -euo pipefail

echo "=== Building Docker image ==="
docker build -t extraction-service .

echo "=== Running e2e tests ==="
make e2e
